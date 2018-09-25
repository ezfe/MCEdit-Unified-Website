//
//  ContributorController.swift
//  App
//
//  Created by Ezekiel Elin on 9/24/18.
//

import Foundation
import Vapor
import Fluent

class ContributorController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: index)
        router.post("update", UUID.parameter, use: update)
    }
    
    func index(_ req: Request) throws -> Future<View> {
        struct ContributorContext: Encodable {
            var contributors: [Contributor]
        }
        
        let contributors = try getContributors(on: req)

        return contributors.flatMap(to: [Contributor].self) { contributors in
            return contributors.map { contributor in
                return ContributorMetaData.query(on: req)
                    .filter(\ContributorMetaData.contributorId == contributor.id)
                    .first()
                    .flatMap(to: ContributorMetaData.self) { cmd in
                    
                        if let cmd = cmd {
                            return Future.map(on: req) { cmd }
                        } else {
                            return ContributorMetaData(id: nil, contributorId: contributor.id).create(on: req)
                        }
                }.map(to: Contributor.self) { cmd in
                    var contributorPlus = contributor
                    contributorPlus.metadata = cmd
                    return contributorPlus
                }
            }.flatten(on: req)
        }.flatMap(to: View.self) { contributors in
            let ctx = ContributorContext(contributors: contributors)
            return try req.view().render("contributors", ctx)
        }
    }
    
    func update(_ req: Request) throws -> Future<Response> {
        let metadataID = try req.parameters.next(UUID.self)
        let roleDescription: String = try req.content.syncGet(at: "description")
        var twitterUsername: String? = try req.content.syncGet(at: "twitterUsername")
        var redditUsername: String? = try req.content.syncGet(at: "redditUsername")
        var youtubeUsername: String? = try req.content.syncGet(at: "youtubeUsername")
        
        if twitterUsername?.isEmpty ?? true {
            twitterUsername = nil
        }
        if redditUsername?.isEmpty ?? true {
            redditUsername = nil
        }
        if youtubeUsername?.isEmpty ?? true {
            youtubeUsername = nil
        }
        
        return ContributorMetaData.query(on: req).filter(\ContributorMetaData.id == metadataID).first().flatMap(to: Response.self) { contributorMetadata in
            
            guard var contributorMetadata = contributorMetadata else {
                throw Abort(.notFound)
            }
            
            return try isAdminAuthed(on: req).flatMap(to: Bool.self) { isAdmin in
                if isAdmin {
                    return Future.map(on: req) { return true }
                } else {
                    return try currentUser(on: req).map(to: Bool.self) { user in
                        return user?.id == contributorMetadata.contributorId
                    }
                }
            }.map(to: Response.self) { editAllowed in
                guard editAllowed else {
                    throw Abort(.forbidden)
                }
                
                print("Found metadata object")
                contributorMetadata.roleDescription = roleDescription
                contributorMetadata.youtubeUsername = youtubeUsername
                contributorMetadata.twitterUsername = twitterUsername
                contributorMetadata.redditUsername = redditUsername
                
                _ = contributorMetadata.save(on: req)
                return req.redirect(to: "/contributors")
            }
        }
    }
}
