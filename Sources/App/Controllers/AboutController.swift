//
//  ArtistPageController.swift
//  TourServer
//
//  Created by Ezekiel Elin on 6/19/18.
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
