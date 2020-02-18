//
//  AuthenticationController.swift
//  App
//
//  Created by Ezekiel Elin on 9/25/18.
//

import Foundation
import Vapor
import FluentPostgresDriver

import PwnedPasswords

let userRegisterErrorSessionKey = "com.ezekielelin.register.error"

class AuthenticationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let authSessionRoutes = routes.grouped(User.authSessionsMiddleware())

        authSessionRoutes.get("login", use: login)
        authSessionRoutes.post(User.LoginRequest.self, at: "login", use: postLogin)
        
        authSessionRoutes.get("register", use: register)
        authSessionRoutes.post(User.RegisterRequest.self, at: "register", use: postRegister)
        
        authSessionRoutes.get("logout", use: logout)
    }
    
    func register(_ req: Request) throws -> EventLoopFuture<View> {
        struct Context: Codable {
            var error: String?
        }
        let ctx = Context(error: req.session[userRegisterErrorSessionKey])

        return try req.view().render("auth/register", ctx)
    }
    
    func postRegister(_ req: Request, data: User.RegisterRequest) throws -> EventLoopFuture<Response> {
        let pwned = PwnedPasswords()
        return try pwned.test(password: data.password, with: req.client)
            .flatMapThrowing { breached in

                let success = req.redirect(to: "/")
                let failure = req.redirect(to: "/auth/register")
                
                guard !breached else {
                    #warning("Re-implement")
//                    req.session[userRegisterErrorSessionKey] = "That password is insecure and not permitted"
                    return EventLoopFuture.map(on: req) { return failure }
                }
                
                let user: User
                do {
                    user = try User(data)
                } catch let err {
                    #warning("Re-implement")
//                    req.session[userRegisterErrorSessionKey] = err.localizedDescription
                    return EventLoopFuture.map(on: req) { return failure }
                }
                
                return user.create(on: req).map(to: Response.self) { user in
                    try req.authenticateSession(user)
                    session[userRegisterErrorSessionKey] = nil
                    return success
                }.mapIfError { error -> Response in
                    session[userRegisterErrorSessionKey] = error.localizedDescription
                    return failure
                }
        }
    }
    
    func login(_ req: Request) throws -> EventLoopFuture<View> {
        req.view.render("auth/login")
    }
    
    func postLogin(_ req: Request, data: User.LoginRequest) throws -> EventLoopFuture<AnyResponse> {

        User.authenticate(username: data.email,
                          password: data.password,
                          using: BCryptDigest(),
                          on: req.db).map { user in

                            guard let user = user else {
                                return AnyResponse(try req.view().render("auth/login", ["error": "Invalid login"]))
                            }

                            try req.authenticateSession(user)

                            let session = try req.session()
                            let redirectTo = session[redirectorSessionUrlKey] ?? "/"
                            session[redirectorSessionUrlKey] = nil

                            return AnyResponse(req.redirect(to: redirectTo))
        }
    }

    func logout(_ req: Request) throws -> Response {
        req.auth.logout(User.self)
        return req.redirect(to: "/")
    }
}
