//
//  AuthenticationController.swift
//  App
//
//  Created by Ezekiel Elin on 9/25/18.
//

import Foundation
import Vapor
import Fluent

import Authentication
import PwnedPasswords

let userRegisterErrorSessionKey = "com.ezekielelin.register.error"

class AuthenticationController: RouteCollection {
    func boot(router: Router) throws {
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())

        authSessionRoutes.get("login", use: login)
        authSessionRoutes.post(User.LoginRequest.self, at: "login", use: postLogin)
        
        authSessionRoutes.get("register", use: register)
        authSessionRoutes.post(User.RegisterRequest.self, at: "register", use: postRegister)
        
        authSessionRoutes.get("logout", use: logout)
    }
    
    func register(_ req: Request) throws -> Future<View> {
        struct Context: Codable {
            var error: String?
        }
        let session = try req.session()
        let ctx = Context(error: session[userRegisterErrorSessionKey])
        
        return try req.view().render("auth/register", ctx)
    }
    
    func postRegister(_ req: Request, data: User.RegisterRequest) throws -> Future<Response> {
        let pwned = PwnedPasswords()
        return try pwned.test(password: data.password, with: req.client())
            .flatMap(to: Response.self) { breached in
                
                let session = try req.session()
                let success = req.redirect(to: "/")
                let failure = req.redirect(to: "/auth/register")
                
                guard !breached else {
                    session[userRegisterErrorSessionKey] = "That password is insecure and not permitted"
                    return Future.map(on: req) { return failure }
                }
                
                let user: User
                do {
                    user = try User(data)
                } catch let err {
                    session[userRegisterErrorSessionKey] = err.localizedDescription
                    return Future.map(on: req) { return failure }
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
    
    func login(_ req: Request) throws -> Future<View> {
        return try req.view().render("auth/login")
    }
    
    func postLogin(_ req: Request, data: User.LoginRequest) throws -> Future<AnyResponse> {
        return User.authenticate(username: data.email,
                                 password: data.password,
                                 using: BCryptDigest(),
                                 on: req).map(to: AnyResponse.self) { user in

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
        try req.unauthenticateSession(User.self)
        return req.redirect(to: "/")
    }
}
