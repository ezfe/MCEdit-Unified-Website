//
//  UserModel.swift
//  App
//
//  Created by Ezekiel Elin on 9/25/18.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

struct User: Content {
    /// The database ID of the exhibit
    ///
    /// This field is managed by PostgreSQL and should
    /// not be set manually for new objects
    var id: Int?
    
    /// Email address for the user
    var email: String
    
    /// The hashed user password
    ///
    /// This field should never be set to the unhashed password
    var password: String
    
    /// The user privileges role
    var role: UserRole
    
    /// Github account ID
    var githubAccessToken: String?
    
    init(email: String, hashedPassword: String, role: UserRole = .regular) {
        self.email = email
        self.password = hashedPassword
        self.role = role
        self.githubAccessToken = nil
    }
    
    init(email: String, plaintextPassword: String, role: UserRole = .regular) throws {
        self.email = email
        self.password = try BCrypt.hash(plaintextPassword)
        self.role = role
        self.githubAccessToken = nil
    }
    
    init(_ registrationData: RegisterRequest) throws {
        try self.init(email: registrationData.email, plaintextPassword: registrationData.password)
    }
    
    func githubDetails(on container: Container) throws -> Future<GithubUser?> {
        var githubFuture: Future<GithubUser?>
        if let access_token = self.githubAccessToken {
            var headers = HTTPHeaders()
            headers.add(name: "Accepts", value: "application/json")
            
            githubFuture = try container.client().get("https://api.github.com/user?access_token=\(access_token)", headers: headers).flatMap(to: GithubUser.self) { response in
                
                return try response.content.decode(GithubUser.self)
            }.map(to: GithubUser?.self) { return $0 }
        } else {
            githubFuture = Future.map(on: container) { return nil }
        }
        return githubFuture
    }
    
    /**
     * Update the password field with a new value
     *
     * This will not save the model, you must call .save() as well
     */
    mutating func changePassword(current currentPassword: String, plaintextNew: String) throws -> Bool {
        if try BCrypt.verify(currentPassword, created: self.password) {
            self.password = try BCrypt.hash(plaintextNew)
            return true
        } else {
            return false
        }
    }
}

//MARK:- Database

extension User: PostgreSQLModel {}
extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.email)
            builder.field(for: \.password)
            builder.field(for: \.role)
            builder.field(for: \.githubAccessToken)
            
            builder.unique(on: \.email)
        }
    }
}

//MARK:- Authentication

extension User: PasswordAuthenticatable {
    static var usernameKey = \User.email
    static var passwordKey = \User.password
}

extension User: SessionAuthenticatable {}

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
