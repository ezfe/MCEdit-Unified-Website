import Routing
import Vapor
import Crypto
import Fluent

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    try router.register(collection: IndexController())
    try router.grouped("about").register(collection: AboutController())
    try router.grouped("tutorial").register(collection: TutorialController())
    try router.grouped("requirements").register(collection: RequirementsController())
    try router.grouped("contributors").register(collection: ContributorController())
    try router.grouped("auth").register(collection: AuthenticationController())
    try router.grouped("user-panel").register(collection: UserPanelController())
    try router.grouped("alert-panel").register(collection: AlertPanelController())    
}

func getLatestRelease(on req: Request) throws -> Future<Release> {
    let url = "https://api.github.com/repos/Podshot/MCEdit-Unified/releases/latest"

    let token = try getServerAccessToken(env: req.environment)
    let headers = HTTPHeaders([("Authorization", "token \(token)")])

    let client = try req.make(Client.self)
    return client.get(url, headers: headers).flatMap(to: GithubRelease.self) { response in
        return try response.content.decode(GithubRelease.self)
    }.map(to: Release.self) { ghRelease in
        guard let release = Release(from: ghRelease) else {
            throw Abort(.internalServerError)
        }
        
        return release
    }
}

func getContributors(on req: Request, as user: User?) throws -> Future<[Contributor]> {
    let url = try "https://api.github.com/repos/Podshot/MCEdit-Unified/contributors?access_token=\(getServerAccessToken(env: req.environment))"
    
    let userGithub = try user?.githubDetails(on: req) ?? Future.map(on: req) { return nil}
    
    let client = try req.make(Client.self)
    return client.get(url).flatMap(to: [GithubContributor].self) { response in
        return try response.content.decode([GithubContributor].self)
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
    let url = try "https://api.github.com/repos/Podshot/MCEdit-Unified/releases?per_page=3&access_token=\(getServerAccessToken(env: req.environment))"
    
    let client = try req.make(Client.self)
    return client.get(url).flatMap(to: [GithubRelease].self) { response in
        return try response.content.decode([GithubRelease].self)
    }.map(to: [Release].self) { ghReleases in
        return ghReleases.compactMap { Release(from: $0) }
    }
}

func getServerAccessToken(env: Environment) throws -> String {
    guard let token = Environment.get("MCEDIT_GITHUB_SERVER_ACCESS_TOKEN") else {
        throw Abort(.internalServerError, reason: "Missing environment variable for Github access token")
    }
    return token
}

func getClientID(env: Environment) throws -> String {
    guard let clientID = Environment.get("MCEDIT_GITHUB_CLIENT_ID") else {
        throw Abort(.internalServerError, reason: "Missing environment variable for Github client ID")
    }
    return clientID
}

func getClientSecret(env: Environment) throws -> String {
    guard let clientSecret = Environment.get("MCEDIT_GITHUB_CLIENT_SECRET") else {
        throw Abort(.internalServerError, reason: "Missing environment variable for Github client secret")
    }
    return clientSecret
}
