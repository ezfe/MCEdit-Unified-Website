//
//  ContributorMetaData.swift
//  App
//
//  Created by Ezekiel Elin on 5/1/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite

struct ContributorMetaData: Content, SQLiteUUIDModel, Migration {
    var id: UUID?
    var contributorId: Int
    var commentURL: String?
}
