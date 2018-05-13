//
//  GithubRelease.swift
//  App
//
//  Created by Ezekiel Elin on 4/6/18.
//

import Vapor
import SwiftMarkdown

/**
 * Container for the data returned from the Github API specifying a specific release
 *
 * Converted to Release object for use in program
 */
struct GithubRelease: Content {
    let htmlURL: String
    let id: Int
    let tagName: String
    let name: String
    let prerelease: Bool
    let publishedAt: String
    let assets: [GithubAsset]
    let body: String
    
    enum CodingKeys: String, CodingKey {
        case htmlURL = "html_url"
        case id
        case tagName = "tag_name"
        case name, prerelease
        case publishedAt = "published_at"
        case assets
        case body
    }
}

/// Specific version of MCEdit
struct Release: Content {
    let htmlURL: String
    let id: Int
    let version: String
    let name: String
    let prerelease: Bool
    let publishedAt: Date
    
    let totalDownloadCount: Int
    let assets: [GithubAsset]
    var mac: GithubAsset?
    var linux: GithubAsset?
    var win32: GithubAsset?
    var win64: GithubAsset?
    
    let releaseNotes: String
    
    var metadata: ReleaseMetaData? = nil
    
    init?(from release: GithubRelease) {
        self.htmlURL = release.htmlURL
        self.id = release.id
        self.version = release.tagName
        self.name = release.name
        self.prerelease = release.prerelease
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let pubDate = dateFormatter.date(from: release.publishedAt) else {
            print("Unable to create date from: \(release.publishedAt)")
            return nil
        }
        self.publishedAt = pubDate
        
        self.totalDownloadCount = release.assets.reduce(0) { (current, asset) -> Int in
            return current + asset.downloadCount
        }
        self.assets = release.assets
        
        /*
         Lin -> Linux
         OSX -> macOS
         Win & 32 -> 32 Bit Windows
         Win & 64 -> 64 Bit Windows
         */
        for asset in release.assets {
            let name = asset.name
            if name.contains("Lin") {
                self.linux = asset
            } else if name.contains("OSX") {
                self.mac = asset
            } else if name.contains("Win") {
                if name.contains("32") {
                    self.win32 = asset
                } else if name.contains("64") {
                    self.win64 = asset
                }
            }
        }
        
        do {
            self.releaseNotes = try markdownToHTML(release.body)
        } catch let err {
            print(err.localizedDescription)
            self.releaseNotes = "?"
        }
    }
}

struct GithubAsset: Content {
    let id: Int
    let name: String
    let downloadCount: Int
    let browserDownloadURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case downloadCount = "download_count"
        case browserDownloadURL = "browser_download_url"
    }
}

protocol GithubIdentity: Content {
    var id: Int { get }
    var login: String { get }
    var avatarURL: String { get }
}

struct GithubUser: GithubIdentity {
    let id: Int
    let login: String
    let avatarURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, login
        case avatarURL = "avatar_url"
    }
}

struct GithubContributor: GithubIdentity {
    let id: Int
    let login: String
    let avatarURL: String
    let contributions: Int
    let htmlURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, login
        case avatarURL = "avatar_url"
        case contributions
        case htmlURL = "html_url"
    }
}

struct Contributor: GithubIdentity {
    var id: Int
    var login: String
    var avatarURL: String
    
    let contributions: Int
    let htmlURL: String

    let editable: Bool
//    let metadata:
    
    init(from contributor: GithubContributor) {
        self.init(from: contributor, editable: false)
    }
    
    init(from contributor: GithubContributor, editable: Bool) {
        self.id = contributor.id
        self.login = contributor.login
        self.avatarURL = contributor.avatarURL
        
        self.contributions = contributor.contributions
        self.htmlURL = contributor.htmlURL
        
        self.editable = editable
    }
}

