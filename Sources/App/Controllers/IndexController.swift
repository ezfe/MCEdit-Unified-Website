//
//  IndexController.swift
//  App
//
//  Created by Ezekiel Elin on 9/30/18.
//

import Foundation
import Vapor
import FluentPostgresDriver

class IndexController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let protectedRoutes = routes.grouped(AuthenticationCheck(level: .manager))

        routes.get(use: index)
        protectedRoutes.get("set-comment-url", ":id", use: setCommentURL)
        protectedRoutes.get("remove-comment-url", ":id", use: removeCommentURL)
    }
    
    func index(_ req: Request) throws -> EventLoopFuture<View> {
        let user = req.auth.get(User.self)
        
        struct Context: Codable {
            let releases: [Release]
            let latestRelease: Release
            let authenticated: Bool
            let alerts: [Alert]
        }
        
        let releasesFuture: EventLoopFuture<[Release]>
        let latestReleaseFuture: EventLoopFuture<Release>

        do {
            releasesFuture = try getReleases(on: req)
            latestReleaseFuture = try getLatestRelease(on: req)
        } catch let err {
            print(err)
            return req.view.render("about", ["error": err.localizedDescription])
        }

        let alertsFuture = Alert.query(on: req.db).filter(\Alert.$isSitewideVisible == true).all()

        return releasesFuture.flatMap { releases in
            releases.map { release -> EventLoopFuture<Release> in
                ReleaseMetaData.query(on: req.db)
                    .filter(\ReleaseMetaData.$releaseID == release.id)
                    .first()
                    .flatMap { releaseMetaData -> EventLoopFuture<ReleaseMetaData> in
                        if let releaseMetaData = releaseMetaData {
                            return req.eventLoop.makeSucceededFuture(releaseMetaData)
                        } else {
                            let metadata = ReleaseMetaData(releaseID: release.id)
                            return metadata.create(on: req.db).map {
                                return metadata
                            }
                        }
                    }.map { releaseMetaData -> Release in
                        var releasePlus = release
                        releasePlus.metadata = releaseMetaData
                        return releasePlus
                    }
                }.flatten(on: req.eventLoop)
        }.flatMap { releases in
            latestReleaseFuture.and(alertsFuture).flatMap { (latestRelease, alerts) in
                let authed = (user?.role ?? .regular) >= .manager

                let context = Context(releases: releases, latestRelease: latestRelease, authenticated: authed, alerts: alerts)
                return req.view.render("index", context)
            }
        }
    }
    
    func setCommentURL(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let metadataID = UUID(uuidString: req.parameters.get("id") ?? "") else {
            throw Abort(.notFound)
        }

        let url: String = try req.content.get(at: "url")
        
        return try updateCommentURL(on: req, id: metadataID, with: url)
    }
    
    func removeCommentURL(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let metadataID = UUID(uuidString: req.parameters.get("id") ?? "") else {
            throw Abort(.notFound)
        }

        return try updateCommentURL(on: req, id: metadataID, with: nil)
    }

    private func updateCommentURL(on req: Request, id: UUID, with url: String?) throws -> EventLoopFuture<Response> {
        return ReleaseMetaData.query(on: req.db)
            .filter(\.$id == id)
            .first()
            .map { releaseMetadata in
                if let releaseMetadata = releaseMetadata {
                    print("Found metadata object")
                    print("assigning url \(String(describing: url))")
                    releaseMetadata.commentURL = url
                    _ = releaseMetadata.save(on: req.db)
                } else {
                    print("No metadata object with id: \(id)")
                }
                return req.redirect(to: "/")
            }
    }
}

