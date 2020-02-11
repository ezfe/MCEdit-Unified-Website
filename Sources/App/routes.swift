import Vapor
import Crypto
import FluentPostgresDriver

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ app: Application) throws {
    try app.register(collection: IndexController())
    try app.grouped("about").register(collection: AboutController())
    try app.grouped("tutorial").register(collection: TutorialController())
    try app.grouped("requirements").register(collection: RequirementsController())
    try app.grouped("contributors").register(collection: ContributorController())
    try app.grouped("auth").register(collection: AuthenticationController())
    try app.grouped("user-panel").register(collection: UserPanelController())
    try app.grouped("alert-panel").register(collection: AlertPanelController())
}

func getLatestRelease(on req: Request) throws -> EventLoopFuture<Release> {
    let url = URI(string: "https://api.github.com/repos/Podshot/MCEdit-Unified/releases/latest")

    let token = try getServerAccessToken(env: req.application.environment)
    let headers = HTTPHeaders([("Authorization", "token \(token)")])

    return req.client.get(url, headers: headers).flatMapThrowing { response -> GithubRelease in
        return try response.content.decode(GithubRelease.self)
    }.flatMapThrowing { ghRelease -> Release in
        guard let release = Release(from: ghRelease) else {
            throw Abort(.internalServerError)
        }
        
        return release
    }
}

func getContributors(on req: Request, as user: User?) throws -> EventLoopFuture<[Contributor]> {
    let url = URI(string: "https://api.github.com/repos/Podshot/MCEdit-Unified/contributors")

    let token = try getServerAccessToken(env: req.application.environment)
    let headers = HTTPHeaders([("Authorization", "token \(token)")])

    let userGithub = try user?.githubDetails(on: req) ?? EventLoopFuture.map(on: req) { return nil}
    
    return req.client.get(url, headers: headers).flatMap(to: [GithubContributor].self) { response in
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

func getReleases(on req: Request) throws -> EventLoopFuture<[Release]> {
    let url = URI(string: "https://api.github.com/repos/Podshot/MCEdit-Unified/releases?per_page=3")

    let token = try getServerAccessToken(env: req.application.environment)
    let headers = HTTPHeaders([("Authorization", "token \(token)")])

    return req.client.get(url, headers: headers).flatMapThrowing { response in
        return try response.content.decode([GithubRelease].self)
    }.map { ghReleases in
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
