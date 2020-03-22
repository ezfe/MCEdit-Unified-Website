//
//  AboutController.swift
//  App
//
//  Created by Ezekiel Elin on 9/24/18.
//

import Foundation
import Vapor

class AboutController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: index)
    }
    
    func index(_ req: Request) throws -> EventLoopFuture<View> {
        return req.view.render("about")
    }
}
