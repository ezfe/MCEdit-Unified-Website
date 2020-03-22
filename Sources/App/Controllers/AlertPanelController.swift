//
//  AlertPanelController.swift
//  App
//
//  Created by Ezekiel Elin on 9/25/18.
//

import Foundation
import Vapor
import FluentPostgresDriver

class AlertPanelController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let protectedRoutes = routes.grouped(AuthenticationCheck(level: .manager))
        
        protectedRoutes.get(use: index)
        protectedRoutes.get("add-alert", use: addAlert)
        protectedRoutes.post("add-alert", use: postAddAlert)
        protectedRoutes.get("remove-alert", ":id", use: removeAlert)
        protectedRoutes.get("show-alert", ":id", use: showAlert)
        protectedRoutes.get("hide-alert", ":id", use: hideAlert)
    }
    
    func index(_ req: Request) throws -> EventLoopFuture<View> {
        struct Context: Codable {
            let alerts: [Alert]
        }

        return Alert.query(on: req.db).all().flatMap { alerts in
            req.view.render("alert_panel", Context(alerts: alerts))
        }
    }
    
    func addAlert(_ req: Request) throws -> EventLoopFuture<View> {
        return req.view.render("add_alert")
    }
    
    func postAddAlert(_ req: Request) throws -> EventLoopFuture<Response> {
        let alert = try req.content.decode(Alert.self)
        return alert.save(on: req.db).map { _ in
            req.redirect(to: "/alert-panel")
        }
    }
    
    func removeAlert(_ req: Request) throws -> EventLoopFuture<Response> {
        Alert.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: req.redirect(to: "/alert-panel"))
    }
    
    func showAlert(_ req: Request) throws -> EventLoopFuture<Response> {
        Alert.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (alert) -> EventLoopFuture<Void> in
                alert.isSitewideVisible = true
                return alert.save(on: req.db)
            }.transform(to: req.redirect(to: "/alert-panel"))
    }
    
    func hideAlert(_ req: Request) throws -> EventLoopFuture<Response> {
        Alert.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { (alert) -> EventLoopFuture<Void> in
                alert.isSitewideVisible = false
                return alert.save(on: req.db)
            }.transform(to: req.redirect(to: "/alert-panel"))
    }
}
