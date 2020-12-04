//
//  AlertModel.swift
//  App
//
//  Created by Ezekiel Elin on 9/25/18.
//

import Foundation
import Vapor
import FluentPostgresDriver

final class Alert: Model {
    static let schema = "alerts"

    /// The database ID of the exhibit
    ///
    /// This field is managed by PostgreSQL and should
    /// not be set manually for new objects
    @ID(custom: "id")
    var id: Int?
    
    /// The title of the alert
    @Field(key: "title")
    var title: String
    
    /// The body of the alert
    @Field(key: "body")
    var body: String
    
    /// Action button
    @Field(key: "learn_more_text")
    var learnMoreText: String
    @Field(key: "learn_more_icon")
    var learnMoreIcon: String?
    @Field(key: "learn_more_url")
    var learnMoreURL: String

    @Field(key: "button_style")
    var buttonStyle: String
    @Field(key: "alert_style")
    var alertStyle: String

    @Field(key: "is_sitewide_visible")
    var isSitewideVisible: Bool
    @Field(key: "user_may_hide")
    var userMayHide: Bool

    init() { }

    init(id: Int? = nil,
         title: String,
         body: String,
         learnMoreText: String,
         learnMoreIcon: String,
         learnMoreURL: String,
         buttonStyle: String,
         alertStyle: String,
         isSitewideVisible: Bool,
         userMayHide: Bool) {

        self.id = id
        self.title = title
        self.body = body
        self.learnMoreText = learnMoreText
        self.learnMoreIcon = learnMoreIcon
        self.learnMoreURL = learnMoreURL
        self.buttonStyle = buttonStyle
        self.alertStyle = alertStyle
        self.isSitewideVisible = isSitewideVisible
        self.userMayHide = userMayHide
    }
}

//MARK:- Database

struct Alert_MigrationCreate: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Alert.schema)
            .field("id", .int, .identifier(auto: true))
            .field("title", .string, .required)
            .field("body", .string, .required)
            .field("learn_more_text", .string, .required)
            .field("learn_more_icon", .string)
            .field("learn_more_url", .string, .required)
            .field("button_style", .string, .required)
            .field("alert_style", .string, .required)
            .field("is_sitewide_visible", .bool, .required)
            .field("user_may_hide", .bool, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Alert.schema).delete()
    }
}
