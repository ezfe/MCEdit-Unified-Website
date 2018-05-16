//
//  ContributorMetaData.swift
//  App
//
//  Created by Ezekiel Elin on 5/1/18.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL

struct ContributorMetaData: Content, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    var contributorId: Int
    
    var roleDescription: String = "Contributor"
    var twitterUsername: String?
    var youtubeUsername: String?
    var redditUsername: String?

    var webcheck: Bool = false
    
    init(id: UUID?, contributorId: Int) {
        self.id = id
        self.contributorId = contributorId
    }
}

struct ContributorMigration1: Migration {
    typealias Database = PostgreSQLDatabase

    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.update(ContributorMetaData.self, on: connection) { builder in
            try builder.field(for: \ContributorMetaData.twitterUsername)
            try builder.field(for: \ContributorMetaData.youtubeUsername)
            try builder.field(for: \ContributorMetaData.redditUsername)
            builder.addField(type: PostgreSQLColumn(type: .bool, default: "false"), name: "webcheck")
        }
    }

    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return Future.map(on: connection) {}
    }
}
