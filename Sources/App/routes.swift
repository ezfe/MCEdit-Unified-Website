import Routing
import Vapor
import Crypto
import Fluent

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    
    let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
    let protectedRoutes = authSessionRoutes.grouped(AuthenticationCheck())
    
    authSessionRoutes.get { req -> Future<View> in
        let user = try req.authenticated(User.self)
        
        struct Context: Codable {
            let releases: [Release]
            let latestRelease: Release
            let authenticated: Bool
            let alerts: [Alert]
        }
        
        let alertsFuture = Alert.query(on: req).filter(\Alert.isSitewideVisible == true).all()
        
        return try getReleases(on: req).flatMap(to: [Release].self) { releases in
            return releases.map { release in
                return ReleaseMetaData.query(on: req).filter(\ReleaseMetaData.releaseID == release.id).first().flatMap(to: ReleaseMetaData.self) { rmd in
                    if let rmd = rmd {
                        return Future.map(on: req) {
                            return rmd
                        }
                    } else {
                        return ReleaseMetaData(id: nil, releaseID: release.id, commentURL: nil).create(on: req)
                    }
                }.map(to: Release.self) { rmd in
                    var releasePlus = release
                    releasePlus.metadata = rmd
                    return releasePlus
                }
            }.flatten(on: req)
        }.flatMap(to: View.self) { releases in
            return try getLatestRelease(on: req).and(alertsFuture).flatMap(to: View.self) { (latestRelease, alerts) in
                let authed = (user?.role ?? .regular) >= .manager
                
                let context = Context(releases: releases, latestRelease: latestRelease, authenticated: authed, alerts: alerts)
                return try req.view().render("index", context)
            }
        }
    }
    
    protectedRoutes.post("setCommentURL", UUID.parameter) { req -> Future<Response> in
        let user = try req.requireAuthenticated(User.self)
        let metadataID = try req.parameters.next(UUID.self)
        let url: String = try req.content.syncGet(at: "url")
        
        return try updateCommentURL(on: req, as: user, id: metadataID, with: url)
    }
    
    protectedRoutes.post("removeCommentURL", UUID.parameter) { req -> Future<Response> in
        let user = try req.requireAuthenticated(User.self)
        let metadataID = try req.parameters.next(UUID.self)
        
        return try updateCommentURL(on: req, as: user, id: metadataID, with: nil)
    }
    
    func updateCommentURL(on req: Request, as user: User, id: UUID, with url: String?) throws -> Future<Response> {
        guard user.role >= .manager else {
            throw Abort(.forbidden)
        }
        
        return ReleaseMetaData.query(on: req).filter(\.id == id).first().map(to: Response.self) { releaseMetadata in
            if var releaseMetadata = releaseMetadata {
                print("Found metadata object")
                print("assigning url \(String(describing: url))")
                releaseMetadata.commentURL = url
                _ = releaseMetadata.save(on: req)
            } else {
                print("No metadata object with id: \(id)")
            }
            return req.redirect(to: "/")
        }
    }
    
    try router.grouped("about").register(collection: AboutController())
    try router.grouped("contributors").register(collection: ContributorController())
    try router.grouped("auth").register(collection: AuthenticationController())
    try router.grouped("user-panel").register(collection: UserPanelController())
    try router.grouped("alert-panel").register(collection: AlertPanelController())

    router.get("tutorial") { req -> Future<View> in
        return try req.view().render("tutorial")
    }
    
    router.get("requirements") { req -> Future<View> in
        return try req.view().render("requirements")
    }
    
    router.get("cache", "invalidate") { req -> String in
        let cache = try req.make(MemoryKeyedCache.self)
        _ = cache.remove("releases")
        return "OK"
    }
    
    router.get("releases") { req -> Future<[Release]> in
        return try getReleases(on: req)
    }
    
    router.get("releases", "current") { req -> Future<Release> in
        return try getLatestRelease(on: req)
    }
}

func getLatestRelease(on req: Request) throws -> Future<Release> {
    let url = "https://api.github.com/repos/Podshot/MCEdit-Unified/releases/latest?access_token=1c9b12b56f2bc1918fee45a564dc53f765854f49"
    
    let cache = try req.make(MemoryKeyedCache.self)
    return cache.get("latest_release", as: Release.self).flatMap(to: Release.self) { release in
        if let release = release {
            /* cache */
            print("Fetching from Cache")
            return Future.map(on: req) {
                return release
            }
        } else {
            /* network */
            let client = try req.make(Client.self)
            return client.get(url).flatMap(to: GithubRelease.self) { response in
                print("Fetching from Internet")
                return try response.content.decode(GithubRelease.self)
                }.flatMap(to: Release.self) { ghRelease in
                    print("Storing in Cache")
                    guard let release = Release(from: ghRelease) else {
                        throw Abort(.internalServerError)
                    }
                    
                    return cache.set("latest_release", to: release).map(to: Release.self) {
                        return release
                    }
            }
        }
    }
}

func getContributors(on req: Request, as user: User?) throws -> Future<[Contributor]> {
    let url = "https://api.github.com/repos/Podshot/MCEdit-Unified/contributors?access_token=1c9b12b56f2bc1918fee45a564dc53f765854f49"
    
    let userGithub = try user?.githubDetails(on: req) ?? Future.map(on: req) { return nil}
    
    let cache = try req.make(MemoryKeyedCache.self)
    return cache.get("contributors", as: [GithubContributor].self).flatMap(to: [GithubContributor].self) { users in
        if let users = users {
            return Future.map(on: req) {
                return users
            }
        } else {
            let client = try req.make(Client.self)
            return client.get(url).flatMap(to: [GithubContributor].self) { response in
                return try response.content.decode([GithubContributor].self)
                }.flatMap(to: [GithubContributor].self) { users in
                    return cache.set("contributors", to: users).map(to: [GithubContributor].self) {
                        return users
                    }
            }
        }
    }.flatMap(to: [Contributor].self) { ghContributors in
        return userGithub.map(to: [Contributor].self) { userGithub in
            let contributors = ghContributors.map { contributor -> Contributor in
                //Set editable to admin status (true if admin, false if not)
                let editable = ((user?.role ?? .regular) >= .manager) || (userGithub?.id == contributor.id)
                return Contributor(from: contributor, editable: editable)
            }
            
            return contributors
        }
    }
}

func getReleases(on req: Request) throws -> Future<[Release]> {
    let url = "https://api.github.com/repos/Podshot/MCEdit-Unified/releases?per_page=3&access_token=\(getServerAccessToken(env: req.environment))"
    
    let cache = try req.make(MemoryKeyedCache.self)
    return cache.get("releases", as: [Release].self).flatMap(to: [Release].self) { releases in
        if let releases = releases {
            // Return the value found in the cache
            return Future.map(on: req) {
                return releases
            }
        } else {
            // Nothing is in the cache, need to make a trip to
            let client = try req.make(Client.self)
            return client.get(url).flatMap(to: [GithubRelease].self) { response in
                return try response.content.decode([GithubRelease].self)
                }.flatMap(to: [Release].self) { ghReleases in
                    let releases = ghReleases.compactMap { Release(from: $0) }
                    
                    return cache.set("releases", to: releases).map(to: [Release].self) {
                        return releases
                    }
            }
        }
    }
}

func getServerAccessToken(env: Environment) -> String {
    return "1c9b12b56f2bc1918fee45a564dc53f765854f49"
}

func getClientID(env: Environment) -> String {
    return env.isRelease ? "4d162dd6f6e9872bbee4" : "f5502eaf4ade48cd63f4"
}

func getClientSecret(env: Environment) -> String {
    return env.isRelease ? "0aceae20334be499b6edc3f395da090d5993b9f6" : "de497386b5fb737fc51ef57c8e4395d6802f58f3"
}
