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
        let protectedRoutes = routes.grouped(AuthenticationCheck())
        
        protectedRoutes.get(use: index)
        protectedRoutes.get("remove-github", use: removeGithub)
        protectedRoutes.get("connect-github", use: connectGithub)
        protectedRoutes.get("connect-github-callback", use: connectGithubCallback)
        
        protectedRoutes.get("change-password", use: changePassword)
        protectedRoutes.post("change-password", use: changePasswordPost)
    }
    
    func index(_ req: Request) throws -> EventLoopFuture<AnyResponse> {
        
        struct UserContext: Encodable {
            let user: User.AuthenticatedUser
            let githubUsername: String?
        }

        let user = try req.auth.require(User.self)
        let authenticatedUser = try user.createPublicView()
        
        return user.githubDetails(on: req).flatMap { githubResponse in
            
            if let githubLogin = githubResponse?.login,
                user.role == .regular,
                ["ezfe", "Podshot", "Khroki", "TrazLander", "naor2013"].contains(githubLogin) {
                
                user.role = .manager
                return user.save(on: req.db).map { _ in
                    return AnyResponse(req.redirect(to: "/user-panel"))
                }
            }
            
            let ctx = UserContext(user: authenticatedUser, githubUsername: githubResponse?.login)

            return req.eventLoop.makeSucceededFuture(
                AnyResponse(req.view.render("user-panel/index", ctx))
            )
        }
    }
    
    func removeGithub(_ req: Request) throws -> EventLoopFuture<Response> {
        let user = try req.auth.require(User.self)
        user.githubAccessToken = nil
        user.role = .regular
        return user.save(on: req.db).map { _ in
            return req.redirect(to: "/user-panel")
        }
    }
    
    func connectGithub(_ req: Request) throws -> Response {
        let stateString = "\(Int.random(in: 100_000...999_999))"
        req.session.data["github_oauth_state"] = stateString
        
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

        if state != req.session.data["github_oauth_state"] {
            print("Expected \(String(describing: req.session.data["github_oauth_state"])) but got \(state)")
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

        let uri = URI(string: "https://github.com/login/oauth/access_token")
        let headers = HTTPHeaders([
            ("Accepts", "application/json")
        ])

        return req.client
            .post(uri, headers: headers, beforeSend: { try $0.content.encode(requestContent) })
            .flatMapThrowing { response in
                try response.content.decode(GithubAccessTokenResponse.self)
            }.flatMapThrowing { response -> EventLoopFuture<Void> in
                let user = try req.auth.require(User.self)
                user.githubAccessToken = response.access_token
                return user.save(on: req.db)
            }.map { _ -> Response in
                req.redirect(to: "/user-panel")
            }
    }
    
    func changePassword(_ req: Request) throws -> EventLoopFuture<View> {
        req.view.render("user-panel/change-password")
    }
    
    func changePasswordPost(_ req: Request) throws -> EventLoopFuture<AnyResponse> {

        let pwRequest = try req.content.decode(User.ChangePasswordRequest.self)
        let user = try req.auth.require(User.self)
        
        if try user.changePassword(current: pwRequest.currentPassword,
                                   plaintextNew: pwRequest.newPassword) {

            return user.save(on: req.db).map { _ in
                return AnyResponse(req.redirect(to: "/user-panel"))
            }
        } else {
            return req.eventLoop.makeSucceededFuture(
                AnyResponse(req.view.render("user-panel/change-password"))
            )
        }
    }
}
