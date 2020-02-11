//
//  ContributorMetaData.swift
//  App
//
//  Created by Ezekiel Elin on 5/1/18.
//

import Foundation
import Vapor
import FluentPostgresDriver

final class ContributorMetaData: Model {
    static let schema = "contributor_metadata"

    @ID(key: "id")
    var id: UUID?

    @Field(key: "contributor_id")
    var contributorId: Int

    @Field(key: "role_description")
    var roleDescription: String

    @Field(key: "twitter_username")
    var twitterUsername: String?

    @Field(key: "youtube_username")
    var youtubeUsername: String?

    @Field(key: "reddit_username")
    var redditUsername: String?

    init() {}

    init(id: UUID?, contributorId: Int) {
        self.id = id
        self.contributorId = contributorId
        self.roleDescription = "Contributor"
    }
}

struct ContributorMetaData_MigrationCreate: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("contributor_metadata")
            .field("id", .uuid, .identifier(auto: true))
            .field("contributor_id", .int)
            .field("role_description", .string)
            .field("twitter_username", .string)
            .field("youtube_username", .string)
            .field("reddit_username", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("contributor_metadata").delete()
    }
}
