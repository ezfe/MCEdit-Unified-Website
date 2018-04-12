//
//  ReleaseMetaData.swift
//  App
//
//  Created by Ezekiel Elin on 4/10/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite

struct ReleaseMetaData: Content, SQLiteUUIDModel, Migration {
    var id: UUID?
    var releaseID: Int
    var commentURL: String?
}
