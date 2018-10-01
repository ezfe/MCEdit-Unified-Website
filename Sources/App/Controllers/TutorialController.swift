//
//  TutorialController.swift
//  App
//
//  Created by Ezekiel Elin on 9/30/18.
//

import Foundation
import Vapor

class TutorialController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: index)
    }
    
    func index(_ req: Request) throws -> Future<View> {
        return try req.view().render("tutorial")
    }
}
