//
//  IndexController.swift
//  App
//
//  Created by Ezekiel Elin on 9/30/18.
//

import Foundation
import Vapor
import FluentPostgreSQL

class IndexController: RouteCollection {
    func boot(router: Router) throws {
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        let protectedRoutes = authSessionRoutes.grouped(AuthenticationCheck(level: .manager))

        authSessionRoutes.get(use: index)
        protectedRoutes.get("set-comment-url", UUID.parameter, use: setCommentURL)
        protectedRoutes.get("remove-comment-url", UUID.parameter, use: removeCommentURL)
    }
    
    func index(_ req: Request) throws -> Future<View> {
        let user = try req.authenticated(User.self)
        
        struct Context: Codable {
            let releases: [Release]
            let latestRelease: Release
            let authenticated: Bool
            let alerts: [Alert]
        }
        
        let alertsFuture = Alert.query(on: req).filter(\Alert.isSitewideVisible == true).all()
        
        return try getReleases(on: req).flatMap(to: [Release].self) { releases in
            return releases.map { release in
                return ReleaseMetaData.query(on: req).filter(\ReleaseMetaData.releaseID == release.id).first().flatMap(to: ReleaseMetaData.self) { rmd in
                    if let rmd = rmd {
                        return Future.map(on: req) {
                            return rmd
                        }
                    } else {
                        return ReleaseMetaData(id: nil, releaseID: release.id, commentURL: nil).create(on: req)
                    }
                }.map(to: Release.self) { rmd in
                    var releasePlus = release
                    releasePlus.metadata = rmd
                    return releasePlus
                }
            }.flatten(on: req)
        }.flatMap(to: View.self) { releases in
            return try getLatestRelease(on: req).and(alertsFuture).flatMap(to: View.self) { (latestRelease, alerts) in
                let authed = (user?.role ?? .regular) >= .manager
                
                let context = Context(releases: releases, latestRelease: latestRelease, authenticated: authed, alerts: alerts)
                return try req.view().render("index", context)
            }
        }
    }
    
    func setCommentURL(_ req: Request) throws -> Future<Response> {
        let metadataID = try req.parameters.next(UUID.self)
        let url: String = try req.content.syncGet(at: "url")
        
        return try updateCommentURL(on: req, id: metadataID, with: url)
    }
    
    func removeCommentURL(_ req: Request) throws -> Future<Response> {
        let metadataID = try req.parameters.next(UUID.self)
        return try updateCommentURL(on: req, id: metadataID, with: nil)
    }

    private func updateCommentURL(on req: Request, id: UUID, with url: String?) throws -> Future<Response> {
        return ReleaseMetaData.query(on: req).filter(\.id == id).first().map(to: Response.self) { releaseMetadata in
            if var releaseMetadata = releaseMetadata {
                print("Found metadata object")
                print("assigning url \(String(describing: url))")
                releaseMetadata.commentURL = url
                _ = releaseMetadata.save(on: req)
            } else {
                print("No metadata object with id: \(id)")
            }
            return req.redirect(to: "/")
        }
    }
}
