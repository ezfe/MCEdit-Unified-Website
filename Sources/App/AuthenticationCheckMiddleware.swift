//
//  LoginRedirector.swift
//  TourServer
//
//  Created by Ezekiel Elin on 6/19/18.
//

import Foundation
import Vapor
import Authentication

let redirectorSessionUrlKey = "com.ezekielelin.loginRedirector.sessionUrlKey"

enum AuthenticationFailureAction {
    case redirect(String)
    case accessProhibitedPage
}

/// A custom middle ware that saves a previous URL for redirecting the user back
///
/// Use `session[redirectorSessionUrlKey]` to get the URL
struct AuthenticationCheck: Middleware {

    /// The action if the user is not logged in
    let unauthenticatedAction: AuthenticationFailureAction
    
    /// The action if the user is logged in, but does not have
    /// the required privileges
    let insufficientPrivilegesAction: AuthenticationFailureAction
    
    /// The level the user must be
    let level: UserRole
    
    /// Initialise the `LoginRedirector`
    ///
    /// - parameters:
    ///    - path: The path to redirect to if the request is not authenticated
    ///    - level: The authentication level required for authentication to succeed
    init(unauthenticated: AuthenticationFailureAction = .redirect("/auth/login"),
         insufficient: AuthenticationFailureAction = .accessProhibitedPage,
         level: UserRole = .regular) {
        
        self.unauthenticatedAction = unauthenticated
        self.insufficientPrivilegesAction = insufficient
        self.level = level
    }
    
    func respond(to req: Request, chainingTo next: Responder) throws -> Future<Response> {
        guard let user = try req.authenticated(User.self) else {
            return try unauthenticated(req)
        }
        
        guard user.role >= self.level else {
            return try insufficientPrivileges(req, user: user)
        }
        
        return try next.respond(to: req)
    }
    
    private func unauthenticated(_ req: Request) throws -> Future<Response> {
        return try self.performAction(req, action: self.unauthenticatedAction)
    }
    
    private func insufficientPrivileges(_ req: Request, user: User) throws -> Future<Response> {
        return try self.performAction(req, action: self.insufficientPrivilegesAction, for: user)
    }
    
    private func performAction(_ req: Request, action: AuthenticationFailureAction, for user: User? = nil) throws -> Future<Response> {
        struct Context: Codable {
            let user: User?
        }
        let ctx = Context(user: user)
        
        switch action {
        case .redirect(let path):
            if req.http.method == .GET, let session = try? req.session() {
                session[redirectorSessionUrlKey] = req.http.urlString
            }
            
            return req.eventLoop.newSucceededFuture(result: req.redirect(to: path))
        case .accessProhibitedPage:
            return try req.view().render("access-prohibited", ctx).flatMap(to: Response.self) { view in
                return try view.encode(for: req)
            }
        }
    }
}