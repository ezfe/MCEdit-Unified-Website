//
//  UserRole.swift
//  App
//
//  Created by Ezekiel Elin on 9/25/18.
//

import Foundation
import FluentPostgresDriver

public enum UserRole: String, Comparable, Codable {
    /// The user has no special access
    ///
    /// This should apply to all accounts created via public-facing portals
    case regular
    
    /// The user has access to most functionality on the website
    ///
    /// This should be used for people who are allowed to modify the art-content of the website
    case manager
    
    /// The user has access to all functionality on the website
    ///
    /// This should be used for people who are allowed to modify any content on the website
    case admin
    
    public static let allCases: [UserRole] = [.regular, .manager, .admin]
    
    public static func <(lhs: UserRole, rhs: UserRole) -> Bool {
        switch lhs {
        case .regular:
            return rhs == .manager || rhs == .admin
        case .manager:
            return rhs == .admin
        case .admin:
            return false
        }
    }
}
