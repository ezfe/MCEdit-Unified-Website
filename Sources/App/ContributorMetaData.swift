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
    var roleDescription: String?
    
    init(id: UUID?, contributorId: Int, roleDescription: String?) {
        self.id = id
        self.contributorId = contributorId
        self.roleDescription = roleDescription
    }
}
