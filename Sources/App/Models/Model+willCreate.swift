//
//  Model+willCreate.swift
//  App
//
//  Created by Ezekiel Elin on 9/25/18.
//

import Vapor
import FluentPostgreSQL

extension PostgreSQLModel {
    /// Prevent model creations with the ID field filled
    public func willCreate(on connection: PostgreSQLConnection) throws -> EventLoopFuture<Self> {
        if self.id != nil {
            throw Abort(.forbidden, reason: "Cannot create model with ID")
        }
        return Future.map(on: connection) { self }
    }
}
