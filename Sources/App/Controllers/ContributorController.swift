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
        routes.get(use: index)
        
        let manager = routes.grouped(AuthenticationCheck(level: .manager))
        manager.post("update", ":id", use: update)
    }
    
    func index(_ req: Request) throws -> EventLoopFuture<View> {
        let user = try req.auth.require(User.self)
        
        struct ContributorContext: Encodable {
            var contributors: [Contributor]
        }
        
        let contributors = try getContributors(on: req, as: user)

        return contributors.flatMap { contributors in
            contributors.map { contributor in
                ContributorMetaData.query(on: req.db)
                    .filter(\.$contributorId == contributor.id)
                    .first()
                    .flatMap { cmd in
                        if let cmd = cmd {
                            return req.eventLoop.makeSucceededFuture(cmd)
                        } else {
                            let cmd = ContributorMetaData(id: nil, contributorId: contributor.id)
                            return cmd.create(on: req.db).map { cmd }
                        }
                    }.map { (cmd: ContributorMetaData) -> Contributor in
                        var _contributor = contributor
                        _contributor.metadata = cmd
                        return _contributor
                    }
            }.flatten(on: req.eventLoop).flatMap { contributors in
                let ctx = ContributorContext(contributors: contributors)
                return req.view.render("contributors", ctx)
            }
        }
    }
    
    func update(_ req: Request) throws -> EventLoopFuture<Response> {
        let user = try req.auth.require(User.self)

        guard let metadataID = UUID(uuidString: req.parameters.get("id") ?? "") else {
            throw Abort(.notFound)
        }

        let roleDescription: String = try req.content.get(at: "description")
        var twitterUsername: String? = try req.content.get(at: "twitterUsername")
        var redditUsername: String? = try req.content.get(at: "redditUsername")
        var youtubeUsername: String? = try req.content.get(at: "youtubeUsername")
        
        if twitterUsername?.isEmpty ?? true {
            twitterUsername = nil
        }
        if redditUsername?.isEmpty ?? true {
            redditUsername = nil
        }
        if youtubeUsername?.isEmpty ?? true {
            youtubeUsername = nil
        }
        
        return ContributorMetaData.query(on: req.db)
            .filter(\.$id == metadataID)
            .first()
            .flatMap { contributorMetadata in
                user.githubDetails(on: req).flatMapThrowing { userGithubDetails in

                    guard user.role >= .manager
                        || userGithubDetails?.id == contributorMetadata?.contributorId else {
                        throw Abort(.forbidden)
                    }
                    
                    guard let contributorMetadata = contributorMetadata else {
                        throw Abort(.notFound)
                    }
                    
                    contributorMetadata.roleDescription = roleDescription
                    contributorMetadata.youtubeUsername = youtubeUsername
                    contributorMetadata.twitterUsername = twitterUsername
                    contributorMetadata.redditUsername = redditUsername
                    
                    _ = contributorMetadata.save(on: req.db)
                    return req.redirect(to: "/contributors")

                }
        }
    }
}
