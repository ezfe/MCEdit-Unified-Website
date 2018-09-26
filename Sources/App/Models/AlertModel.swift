//
//  AlertModel.swift
//  App
//
//  Created by Ezekiel Elin on 9/25/18.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct Alert: Content {
    /// The database ID of the exhibit
    ///
    /// This field is managed by PostgreSQL and should
    /// not be set manually for new objects
    var id: Int?
    
    /// The title of the alert
    var title: String
    
    /// The body of the alert
    var body: String
    
    /// Action button
    var learnMoreText: String
    var learnMoreIcon: String?
    var learnMoreURL: String
    
    var buttonStyle: String
    var alertStyle: String
    
    var isSitewideVisible: Bool
    var userMayHide: Bool
}

//MARK:- Database

extension Alert: PostgreSQLModel {}
extension Alert: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.body)
            builder.field(for: \.learnMoreText)
            builder.field(for: \.learnMoreIcon)
            builder.field(for: \.learnMoreURL)
            builder.field(for: \.alertStyle)
            builder.field(for: \.buttonStyle)
            builder.field(for: \.isSitewideVisible)
            builder.field(for: \.userMayHide)
        }
    }
}

extension Alert: Parameter {}
