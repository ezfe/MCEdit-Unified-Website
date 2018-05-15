//
//  ReleaseMetaData.swift
//  App
//
//  Created by Ezekiel Elin on 4/10/18.
//

import Foundation
import Vapor
import Fluent
import FluentPostgreSQL

struct ReleaseMetaData: Content, PostgreSQLUUIDModel, Migration {
    var id: UUID?
    var releaseID: Int
    var commentURL: String?
}
