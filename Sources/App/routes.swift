import Routing
import Vapor
import Crypto
import Fluent

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    
    router.get { req -> Future<View> in
        struct Context: Codable {
            let releases: [Release]
            let latestRelease: Release
            let authenticated: Bool
        }
        
        return try getReleases(on: req).flatMap(to: [Release].self) { releases in
            return try releases.map { release in
                return try ReleaseMetaData.query(on: req).filter(\ReleaseMetaData.releaseID == release.id).first().flatMap(to: ReleaseMetaData.self) { rmd in
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
                return try getLatestRelease(on: req).flatMap(to: View.self) { latestRelease in
                    return try isAdminAuthed(on: req).flatMap(to: View.self) { authed in
                        let context = Context(releases: releases, latestRelease: latestRelease, authenticated: authed)
                        return try req.view().render("index", context)
                    }
                }
        }
    }
    
    router.post("setContributorRoleDescription", UUID.parameter) { req -> Future<Response> in
        let metadataID = try req.parameters.next(UUID.self)
        let text: String = try req.content.syncGet(at: "description")
        
        return try ContributorMetaData.query(on: req).filter(\ContributorMetaData.id == metadataID).first().flatMap(to: Response.self) { contributorMetadata in
            
            guard var contributorMetadata = contributorMetadata else {
                throw Abort(.notFound)
            }
            
            return try isAdminAuthed(on: req).flatMap(to: Bool.self) { isAdmin in
                if isAdmin {
                    return Future.map(on: req) { return true }
                } else {
                    return try currentUser(on: req).map(to: Bool.self) { user in
                        return user?.id == contributorMetadata.contributorId
                    }
                }
            }.map(to: Response.self) { editAllowed in
                guard editAllowed else {
                    throw Abort(.forbidden)
                }
                
                print("Found metadata object")
                print("assigning role description \(text)")
                contributorMetadata.roleDescription = text
                _ = contributorMetadata.save(on: req)
                return req.redirect(to: "/contributors")
            }
        }
    }
    
    router.post("setCommentURL", UUID.parameter) { req -> Future<Response> in
        let metadataID = try req.parameters.next(UUID.self)
        let url: String = try req.content.syncGet(at: "url")
        
        return try updateCommentURL(on: req, id: metadataID, with: url)
    }
    
    router.post("removeCommentURL", UUID.parameter) { req -> Future<Response> in
        let metadataID = try req.parameters.next(UUID.self)
        
        return try updateCommentURL(on: req, id: metadataID, with: nil)
    }
    
    func updateCommentURL(on req: Request, id: UUID, with url: String?) throws -> Future<Response> {
        return try isAdminAuthed(on: req).flatMap(to: Response.self) { authed in
            guard authed else {
                throw Abort(.forbidden)
            }
            
            return try ReleaseMetaData.query(on: req).filter(\.id == id).first().map(to: Response.self) { releaseMetadata in
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
    }
    
    router.get("about") { req -> Future<View> in
        return try req.view().render("about")
    }
    
    router.get("tutorial") { req -> Future<View> in
        return try req.view().render("tutorial")
    }
    
    router.get("requirements") { req -> Future<View> in
        return try req.view().render("requirements")
    }
    
    router.get("contributors") { req -> Future<View> in
        struct ContributorContext: Encodable {
            var contributors: [Contributor]
        }
        
        let contributors = try getContributors(on: req)
        //        let totalContributions = contributors.map { contributors in
        //            return contributors.reduce(0, { (counter, contributor) -> Int in
        //                return counter + contributor.contributions
        //            })
        //        }
        
        //
        return contributors.flatMap(to: [Contributor].self) { contributors in
            return try contributors.map { contributor in
                return try ContributorMetaData.query(on: req).filter(\ContributorMetaData.contributorId == contributor.id).first().flatMap(to: ContributorMetaData.self) { cmd in
                    if let cmd = cmd {
                        return Future.map(on: req) {
                            return cmd
                        }
                    } else {
                        return ContributorMetaData(id: nil, contributorId: contributor.id, roleDescription: "Contributor").create(on: req)
                    }
                    }.map(to: Contributor.self) { cmd in
                        var contributorPlus = contributor
                        contributorPlus.metadata = cmd
                        return contributorPlus
                }
                }.flatten(on: req)
            }.flatMap(to: View.self) { contributors in
                let ctx = ContributorContext(contributors: contributors)
                return try req.view().render("contributors", ctx)
        }
    }
    
    router.get("auth", "new") { req -> Response in
        let session = try req.session()
        let stateString = "12345"
        session["github_oauth_state"] = stateString
        
        let clientID = URLQueryItem(name: "client_id", value: "4d162dd6f6e9872bbee4")
        let state = URLQueryItem(name: "state", value: stateString) //MARK: no
        let allowSignups = URLQueryItem(name: "allow_signup", value: "false")
        
        var components = URLComponents(string: "https://github.com/login/oauth/authorize")
        components?.queryItems = [clientID, state, allowSignups]
        
        return req.redirect(to: components!.url!.absoluteString)
    }
    
    router.get("auth", "callback") { req -> Future<Response> in
        
        let code: String = try req.query.get(at: "code")
        let state: String = try req.query.get(at: "state")
        
        let session = try req.session()
        
        if state != session["github_oauth_state"] {
            print("Expected \(String(describing: session["github_oauth_state"])) but got \(state)")
            throw Abort(.forbidden)
        }
        
        struct GithubAccessTokenRequest: Content {
            let client_id: String
            let client_secret: String
            let code: String
            let state: String
        }
        
        struct GithubAccessTokenResponse: Codable {
            let access_token: String
        }
        
        let requestContent = GithubAccessTokenRequest(client_id: "4d162dd6f6e9872bbee4", client_secret: "0aceae20334be499b6edc3f395da090d5993b9f6", code: code, state: state)
        
        var headers = HTTPHeaders()
        headers.add(name: "Accepts", value: "application/json")
        
        let client = try req.make(Client.self)
        return client.post("https://github.com/login/oauth/access_token", headers: headers, beforeSend: { (req) in
            try req.content.encode(requestContent)
        }).flatMap(to: GithubAccessTokenResponse.self) { response in
            return try response.content.decode(GithubAccessTokenResponse.self)
            }.map(to: Response.self) { GAT in
                session["github_oauth_access_token"] = GAT.access_token
                return req.redirect(to: "/")
        }
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

func currentUser(on req: Request) throws -> Future<GithubUser?> {
    let session = try req.session()
    guard let token = session["github_oauth_access_token"] else {
        return Future.map(on: req) { return nil }
    }
    
    let client = try req.make(Client.self)
    return client.get("https://api.github.com/user?access_token=\(token)").flatMap(to: GithubUser?.self) { response in
        return try response.content.decode(GithubUser?.self)
    }
}

func isAdminAuthed(on req: Request) throws -> Future<Bool> {
    return try currentUser(on: req).map(to: Bool.self) { user in
        if let user = user {
            let whitelisted = ["ezfe", "Podshot", "Khroki", "TrazLander"]
            return whitelisted.contains(user.login)
        } else {
            return false
        }
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

func getContributors(on req: Request) throws -> Future<[Contributor]> {
    let url = "https://api.github.com/repos/Podshot/MCEdit-Unified/contributors?access_token=1c9b12b56f2bc1918fee45a564dc53f765854f49"
    
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
            return try currentUser(on: req).flatMap(to: [Contributor].self) { authedUser in
                return try isAdminAuthed(on: req).map(to: [Contributor].self) { isAdmin in
                    let contributors = ghContributors.map { contributor -> Contributor in
                        //Set editable to admin status (true if admin, false if not)
                        var editable = isAdmin
                        //If still not editable, check the user object
                        if let u = authedUser, !editable {
                            editable = u.login == contributor.login
                        }
                        
                        return Contributor(from: contributor, editable: editable)
                    }
                    
                    return contributors
                }
            }
    }
}

func getReleases(on req: Request) throws -> Future<[Release]> {
    let url = "https://api.github.com/repos/Podshot/MCEdit-Unified/releases?per_page=3&access_token=1c9b12b56f2bc1918fee45a564dc53f765854f49"
    
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
