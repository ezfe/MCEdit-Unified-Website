//
//  RequirementsController.swift
//  App
//
//  Created by Ezekiel Elin on 9/30/18.
//

import Foundation
import Vapor

class RequirementsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: index)
    }
    
    func index(_ req: Request) throws -> EventLoopFuture<View> {
        return try req.view.render("requirements")
    }
}
