//
//  AlertPanelController.swift
//  App
//
//  Created by Ezekiel Elin on 9/25/18.
//

import Foundation
import Vapor
import Fluent
import Authentication

class AlertPanelController: RouteCollection {
    func boot(router: Router) throws {
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        let protectedRoutes = authSessionRoutes.grouped(AuthenticationCheck(level: .manager))
        
        protectedRoutes.get(use: index)
        protectedRoutes.get("add-alert", use: addAlert)
        protectedRoutes.post(Alert.self, at: "add-alert", use: postAddAlert)
        protectedRoutes.get("remove-alert", Alert.parameter, use: removeAlert)
        protectedRoutes.get("show-alert", Alert.parameter, use: showAlert)
        protectedRoutes.get("hide-alert", Alert.parameter, use: hideAlert)
    }
    
    func index(_ req: Request) throws -> Future<View> {
        struct Context: Codable {
            let alerts: [Alert]
        }
        
        return Alert.query(on: req).all().flatMap(to: View.self) { alerts in
            return try req.view().render("alert_panel", Context(alerts: alerts))
        }
    }
    
    func addAlert(_ req: Request) throws -> Future<View> {
        return try req.view().render("add_alert")
    }
    
    func postAddAlert(_ req: Request, alert: Alert) throws -> Future<Response> {
        return alert.save(on: req).map(to: Response.self) { _ in
            return req.redirect(to: "/alert-panel")
        }
    }
    
    func removeAlert(_ req: Request) throws -> Future<Response> {
        let alert = try req.parameters.next(Alert.self)
        return alert.delete(on: req).map(to: Response.self) { _ in
            return req.redirect(to: "/alert-panel")
        }
    }
    
    func showAlert(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Alert.self).flatMap(to: Alert.self) { alert in
            var alert = alert
            alert.isSitewideVisible = true
            return alert.save(on: req)
        }.map(to: Response.self) { _ in
            return req.redirect(to: "/alert-panel")
        }
    }
    
    func hideAlert(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Alert.self).flatMap(to: Alert.self) { alert in
            var alert = alert
            alert.isSitewideVisible = false
            return alert.save(on: req)
        }.map(to: Response.self) { _ in
            return req.redirect(to: "/alert-panel")
        }
    }
}
