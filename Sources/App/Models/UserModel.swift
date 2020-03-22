//
//  UserModel.swift
//  App
//
//  Created by Ezekiel Elin on 9/25/18.
//

import Foundation
import Vapor
import Crypto
import Fluent
import FluentPostgresDriver

final class User: Model {
    static let schema = "users"

    /// The database ID of the exhibit
    ///
    /// This field is managed by PostgreSQL and should
    /// not be set manually for new objects
    var id: Int?
    
    /// Email address for the user
    @Field(key: "email")
    var email: String
    
    /// The hashed user password
    ///
    /// This field should never be set to the unhashed password
    @Field(key: "password_hashed")
    var password: String
    
    /// The user privileges role
    @Field(key: "role")
    var role: UserRole
    
    /// Github account ID
    @Field(key: "github_access_token")
    var githubAccessToken: String?

    init() {}

    init(email: String, hashedPassword: String, role: UserRole = .regular) {
        self.email = email
        self.password = hashedPassword
        self.role = role
        self.githubAccessToken = nil
    }
    
    init(email: String, plaintextPassword: String, role: UserRole = .regular) throws {
        self.email = email
        self.password = try Bcrypt.hash(plaintextPassword)
        self.role = role
        self.githubAccessToken = nil
    }
    
    convenience init(_ registrationData: RegisterRequest) throws {
        try self.init(email: registrationData.email, plaintextPassword: registrationData.password)
    }
    
    func githubDetails(on req: Request) -> EventLoopFuture<GithubUser?> {
        var githubFuture: EventLoopFuture<GithubUser?>
        if let access_token = self.githubAccessToken {
            var headers = HTTPHeaders()
            headers.add(name: "Accepts", value: "application/json")
            headers.add(name: "Authorization", value: "token \(access_token)")

            let uri = URI(string: "https://api.github.com/user")
            githubFuture = req.client
                .get(uri, headers: headers)
                .flatMapThrowing { response -> GithubUser in
                    return try response.content.decode(GithubUser.self)
                }
        } else {
            return req.eventLoop.makeSucceededFuture(nil)
        }
        return githubFuture
    }
    
    /**
     * Update the password field with a new value
     *
     * This will not save the model, you must call .save() as well
     */
    func changePassword(current currentPassword: String, plaintextNew: String) throws -> Bool {
        if try Bcrypt.verify(currentPassword, created: self.password) {
            self.password = try Bcrypt.hash(plaintextNew)
            return true
        } else {
            return false
        }
    }
}

//MARK:- Database

struct User_MigrationCreate: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(User.schema)
            .field("id", .int, .identifier(auto: true))
            .field("email",  .string)
            .field("password", .string)
//            .field("role", .enum(UserRole.self))
            .field("github_access_token", .string)
            .unique(on: "email")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(User.schema).delete()
    }
}

//MARK:- Authentication

extension User: SessionAuthenticatable {
    typealias SessionID = User.IDValue

    var sessionID: IDValue? {
        return self.id
    }
}

extension User: ModelUser {
    static var usernameKey = \User.$email
    static var passwordHashKey = \User.$password

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

//MARK: Login and Registration objects

extension User {
    struct LoginRequest: Content {
        var email: String
        var password: String
    }
    
    struct RegisterRequest: Content {
        var email: String
        var password: String
    }
    
    struct ChangePasswordRequest: Content {
        let currentPassword: String
        let newPassword: String
    }
}

//MARK:- Authenticated User

extension User {
    public struct AuthenticatedUser: Content {
        public let id: Int
        public let email: String
        public let role: UserRole
        
        init(id: Int, email: String, role: UserRole, githubId: Int? = nil) {
            self.id = id
            self.email = email
            self.role = role
        }
    }
    
    /// Create a public representation of the object
    ///
    /// Public representations are used when certain fields
    /// are intended to be omitted, or when certain data structures
    /// need to be reorganized for the endpoints.
    func createPublicView() throws -> AuthenticatedUser {
        return try AuthenticatedUser(id: self.requireID(), email: self.email, role: self.role)
    }
}
