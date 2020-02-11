//
//  UserPanelController.swift
//  App
//
//  Created by Ezekiel Elin on 9/25/18.
//

import Foundation
import Vapor
import FluentPostgresDriver

class UserPanelController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let authSessionRoutes = routes.grouped(User.authSessionsMiddleware())
        let protectedRoutes = authSessionRoutes.grouped(AuthenticationCheck())
        
        protectedRoutes.get(use: index)
        protectedRoutes.get("remove-github", use: removeGithub)
        protectedRoutes.get("connect-github", use: connectGithub)
        protectedRoutes.get("connect-github-callback", use: connectGithubCallback)
        
        protectedRoutes.get("change-password", use: changePassword)
        protectedRoutes.post(User.ChangePasswordRequest.self, at: "change-password", use: changePasswordPost)
    }
    
    func index(_ req: Request) throws -> EventLoopFuture<AnyResponse> {
        
        struct UserContext: Encodable {
            let user: User.AuthenticatedUser
            let githubUsername: String?
        }

        var user = try req.requireAuthenticated(User.self)
        let authenticatedUser = try user.createPublicView()
        
        return try user.githubDetails(on: req).flatMap(to: AnyResponse.self) { githubResponse in
            
            if let githubLogin = githubResponse?.login,
                user.role == .regular,
                ["ezfe", "Podshot", "Khroki", "TrazLander", "naor2013"].contains(githubLogin) {
                
                user.role = .manager
                return user.save(on: req).map(to: AnyResponse.self) { _ in
                    return AnyResponse(req.redirect(to: "/user-panel"))
                }
            }
            
            let ctx = UserContext(user: authenticatedUser, githubUsername: githubResponse?.login)
            
            return Future.map(on: req) {
                return try AnyResponse(req.view().render("user-panel/index", ctx))
            }
        }
    }
    
    func removeGithub(_ req: Request) throws -> EventLoopFuture<Response> {
        var user = try req.requireAuthenticated(User.self)
        user.githubAccessToken = nil
        user.role = .regular
        return user.save(on: req).map(to: Response.self) { _ in
            return req.redirect(to: "/user-panel")
        }
    }
    
    func connectGithub(_ req: Request) throws -> Response {
        let stateString = "\(Int.random(in: 100_000...999_999))"
        req.session["github_oauth_state"] = stateString
        
        let clientIdValue = try getClientID(env: req.application.environment)
        
        let clientID = URLQueryItem(name: "client_id", value: clientIdValue)
        let state = URLQueryItem(name: "state", value: stateString)
        
        guard var components = URLComponents(string: "https://github.com/login/oauth/authorize") else {
            throw Abort(.internalServerError)
        }
        components.queryItems = [clientID, state]
        
        guard let githubUrl = components.url?.absoluteString else {
            throw Abort(.internalServerError)
        }
        
        return req.redirect(to: githubUrl)
    }
    
    func connectGithubCallback(_ req: Request) throws -> EventLoopFuture<Response> {
        let code: String = try req.query.get(at: "code")
        let state: String = try req.query.get(at: "state")

        if state != req.session["github_oauth_state"] {
            print("Expected \(String(describing: req.session["github_oauth_state"])) but got \(state)")
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

        let clientID = try getClientID(env: req.application.environment)
        let clientSecret = try getClientSecret(env: req.application.environment)
        let requestContent = GithubAccessTokenRequest(client_id: clientID,
                                                          client_secret: clientSecret,
                                                          code: code,
                                                          state: state)
        
        var headers = HTTPHeaders([
            ("Accepts", "application/json")
        ])

        return req.client.post("https://github.com/login/oauth/access_token",
                               headers: headers,
                               beforeSend: { $0.content.encode(requestContent) })
            .flatMapThrowing { response in
                try response.content.decode(GithubAccessTokenResponse.self)
            }.flatMapThrowing { response in
                var user = try req.requireAuthenticated(User.self)
                user.githubAccessToken = response.access_token
                return user.save(on: req)
            }.map { user -> Response in
                req.redirect(to: "/user-panel")
            }
    }
    
    func changePassword(_ req: Request) throws -> EventLoopFuture<View> {
        req.view.render("user-panel/change-password")
    }
    
    func changePasswordPost(_ req: Request,
                            pwRequest: User.ChangePasswordRequest) throws -> EventLoopFuture<AnyResponse> {
        
        var user = try req.requireAuthenticated(User.self)
        
        if try user.changePassword(current: pwRequest.currentPassword, plaintextNew: pwRequest.newPassword) {
            return user.save(on: req).map(to: AnyResponse.self) { _ in
                return AnyResponse(req.redirect(to: "/user-panel"))
            }
        } else {
            return EventLoopFuture.map(on: req) {
                try AnyResponse(req.view().render("user-panel/change-password"))
            }
        }
    }
}
