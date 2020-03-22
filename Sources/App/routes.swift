import Vapor
import Crypto
import FluentPostgresDriver

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ app: Application) throws {
    let authed = app.grouped(app.fluent.sessions.middleware(for: User.self))
    try authed.register(collection: IndexController())
    try authed.grouped("about").register(collection: AboutController())
    try authed.grouped("tutorial").register(collection: TutorialController())
    try authed.grouped("requirements").register(collection: RequirementsController())
    try authed.grouped("contributors").register(collection: ContributorController())
    try authed.grouped("auth").register(collection: AuthenticationController())
    try authed.grouped("user-panel").register(collection: UserPanelController())
    try authed.grouped("alert-panel").register(collection: AlertPanelController())
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
    let uri = URI(string: "https://api.github.com/repos/Podshot/MCEdit-Unified/contributors")

    let token = try getServerAccessToken(env: req.application.environment)
    let headers = HTTPHeaders([("Authorization", "token \(token)")])

    let userGithub = user?.githubDetails(on: req) ?? req.eventLoop.makeSucceededFuture(nil)

    return req.client.get(uri, headers: headers)
        .flatMapThrowing { response in
            return try response.content.decode([GithubContributor].self)
        }.flatMap { githubContributors in
            return userGithub.map { userGithub -> [Contributor] in
                let contributors = githubContributors.map { contributor -> Contributor in
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
