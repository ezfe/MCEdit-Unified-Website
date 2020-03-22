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
        routes.get("login", use: login)
        routes.post("login", use: postLogin)
        
        routes.get("register", use: register)
        routes.post("register", use: postRegister)
        
        routes.get("logout", use: logout)
    }
    
    func register(_ req: Request) throws -> EventLoopFuture<View> {
        struct Context: Codable {
            var error: String?
        }
        let ctx = Context(error: req.session.data[userRegisterErrorSessionKey])

        return req.view.render("auth/register", ctx)
    }
    
    func postRegister(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(User.RegisterRequest.self)
        
        return try req.pwnedPasswords.test(password: data.password).flatMap { breached in

                let success = req.redirect(to: "/")
                let failure = req.redirect(to: "/auth/register")
                
                guard !breached else {
                    req.session.data[userRegisterErrorSessionKey] = "That password is insecure and not permitted"
                    return req.eventLoop.makeSucceededFuture(failure)
                }
                
                let user: User
                do {
                    user = try User(data)
                } catch let err {
                    req.session.data[userRegisterErrorSessionKey] = err.localizedDescription
                    return req.eventLoop.makeSucceededFuture(failure)
                }

                return user.create(on: req.db).map { _ -> Response in
                    req.auth.login(user)
                    req.session.data[userRegisterErrorSessionKey] = nil
                    return success
                }
        }
    }
    
    func login(_ req: Request) throws -> EventLoopFuture<View> {
        req.view.render("auth/login")
    }
    
    func postLogin(_ req: Request) throws -> EventLoopFuture<AnyResponse> {
        let data = try req.content.decode(User.LoginRequest.self)

        return User.query(on: req.db)
            .filter(\.$email == data.email)
            .first()
            .map { user -> AnyResponse in
                guard let user = user else {
                    return AnyResponse(
                        req.view.render("auth/login",["error": "Invalid login"])
                    )
                }

                req.auth.login(user)

                let redirectTo = req.session.data[redirectorSessionUrlKey] ?? "/"
                req.session.data[redirectorSessionUrlKey] = nil

                return AnyResponse(req.redirect(to: redirectTo))
            }
    }

    func logout(_ req: Request) throws -> Response {
        req.auth.logout(User.self)
        return req.redirect(to: "/")
    }
}
