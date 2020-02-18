//
//  ContributorController.swift
//  App
//
//  Created by Ezekiel Elin on 9/24/18.
//

import Foundation
import Vapor
import FluentPostgresDriver

class ContributorController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let loSessionRoutes = routes.grouped(User.authSessionsMiddleware())
        authSessionRoutes.get(use: index)
        
        let manager = authSessionRoutes.grouped(AuthenticationCheck())
        manager.post("update", UUID.parameter, use: update)
    }
    
    func index(_ req: Request) throws -> EventLoopFuture<View> {
        let user = try req.authenticated(User.self)
        
        struct ContributorContext: Encodable {
            var contributors: [Contributor]
        }
        
        let contributors = try getContributors(on: req, as: user)

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
    
    func update(_ req: Request) throws -> EventLoopFuture<Response> {
        let user = try req.requireAuthenticated(User.self)
        
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
        
        return ContributorMetaData.query(on: req)
            .filter(\ContributorMetaData.id == metadataID)
            .first()
            .flatMap(to: Response.self) { contributorMetadata in
            
                return try user.githubDetails(on: req).map(to: Response.self) { userGithubDetails in
                    guard user.role >= .manager || userGithubDetails?.id == contributorMetadata?.contributorId else {
                        throw Abort(.forbidden)
                    }
                    
                    guard var contributorMetadata = contributorMetadata else {
                        throw Abort(.notFound)
                    }
                    
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
