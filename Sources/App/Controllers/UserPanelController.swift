//
//  UserPanelController.swift
//  App
//
//  Created by Ezekiel Elin on 9/25/18.
//

import Foundation
import Vapor
import Fluent
import Authentication

class UserPanelController: RouteCollection {
    func boot(router: Router) throws {
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        let protectedRoutes = authSessionRoutes.grouped(AuthenticationCheck())
        
        protectedRoutes.get(use: index)
        protectedRoutes.get("remove-github", use: removeGithub)
        protectedRoutes.get("connect-github", use: connectGithub)
        protectedRoutes.get("connect-github-callback", use: connectGithubCallback)
        
        protectedRoutes.get("change-password", use: changePassword)
        protectedRoutes.post(User.ChangePasswordRequest.self, at: "change-password", use: changePasswordPost)
    }
    
    func index(_ req: Request) throws -> Future<AnyResponse> {
        
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
    
    func removeGithub(_ req: Request) throws -> Future<Response> {
        var user = try req.requireAuthenticated(User.self)
        user.githubAccessToken = nil
        user.role = .regular
        return user.save(on: req).map(to: Response.self) { _ in
            return req.redirect(to: "/user-panel")
        }
    }
    
    func connectGithub(_ req: Request) throws -> Response {
        let session = try req.session()
        let stateString = "\(Int.random(in: 100_000...999_999))"
        session["github_oauth_state"] = stateString
        
        let clientIdValue = try getClientID(env: req.environment)
        
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
    
    func connectGithubCallback(_ req: Request) throws -> Future<Response> {
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
        
        let requestContent = try GithubAccessTokenRequest(client_id: getClientID(env: req.environment),
                                                      client_secret: getClientSecret(env: req.environment),
                                                      code: code,
                                                      state: state)
        
        var headers = HTTPHeaders()
        headers.add(name: "Accepts", value: "application/json")
        
        let client = try req.make(Client.self)
        return client.post("https://github.com/login/oauth/access_token", headers: headers, beforeSend: { (req) in
            try req.content.encode(requestContent)
        }).flatMap(to: GithubAccessTokenResponse.self) { response in
            return try response.content.decode(GithubAccessTokenResponse.self)
        }.flatMap(to: User.self) { response in
            var user = try req.requireAuthenticated(User.self)
            user.githubAccessToken = response.access_token
            return user.save(on: req)
        }.map(to: Response.self) { user in
            return req.redirect(to: "/user-panel")
        }
    }
    
    func changePassword(_ req: Request) throws -> Future<View> {
        return try req.view().render("user-panel/change-password")
    }
    
    func changePasswordPost(_ req: Request, pwRequest: User.ChangePasswordRequest) throws -> Future<AnyResponse> {
        var user = try req.requireAuthenticated(User.self)
        
        if try user.changePassword(current: pwRequest.currentPassword, plaintextNew: pwRequest.newPassword) {
            return user.save(on: req).map(to: AnyResponse.self) { _ in
                return AnyResponse(req.redirect(to: "/user-panel"))
            }
        } else {
            return Future.map(on: req) {
                try AnyResponse(req.view().render("user-panel/change-password"))
            }
        }
    }
}
