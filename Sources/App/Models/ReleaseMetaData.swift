//
//  ReleaseMetaData.swift
//  App
//
//  Created by Ezekiel Elin on 4/10/18.
//

import Foundation
import Vapor
import FluentPostgresDriver

final class ReleaseMetaData: Model {
    static let schema = "contributor_metadata"

    @ID(key: "id")
    var id: UUID?

    @Field(key: "release_id")
    var releaseID: Int

    @Field(key: "comment_url")
    var commentURL: String?

    init() {}

    init(id: UUID? = nil, releaseID: Int, commentURL: String? = nil) {
        self.id = id
        self.releaseID = releaseID
        self.commentURL = commentURL
    }
}
