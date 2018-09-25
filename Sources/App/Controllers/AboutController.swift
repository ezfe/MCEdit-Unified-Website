//
//  AboutController.swift
//  App
//
//  Created by Ezekiel Elin on 9/24/18.
//

import Foundation
import Vapor

class AboutController: RouteCollection {
    func boot(router: Router) throws {        
        router.get(use: index)
    }
    
    func index(_ req: Request) throws -> Future<View> {
        return try req.view().render("about")
    }
}
