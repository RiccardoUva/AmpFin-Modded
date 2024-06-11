//
//  JellyfinApi.swift
//  Music
//
//  Created by Rasmus Krämer on 06.09.23.
//

import Foundation
import SwiftUI
import OSLog

/// API client for the Jellyfin server
@Observable
public final class JellyfinClient {
    public private(set) var serverUrl: URL!
    public private(set) var token: String!
    public private(set) var userId: String!
    
    public private(set) var clientVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    
    public private(set) var clientId: String
    
    #if os(iOS)
    public let deviceType = "iOS"
    #else
    public let deviceType = "unknown"
    #endif
    
    let logger = Logger(subsystem: "io.rfk.ampfin", category: "HTTP")
    static let defaults = AFKIT_ENABLE_ALL_FEATURES ? UserDefaults(suiteName: "group.io.rfk.ampfin")! : UserDefaults.standard
    
    init(serverUrl: URL!, token: String?, userId: String?) {
        if !AFKIT_ENABLE_ALL_FEATURES {
            logger.warning("User data will not be stored in an app group")
        }
        
        self.serverUrl = serverUrl
        self.token = token
        self.userId = userId
        
        if let clientId = Self.defaults.string(forKey: "clientId") {
            self.clientId = clientId
        } else {
            clientId = String.random(length: 100)
            Self.defaults.set(clientId, forKey: "clientId")
        }
    }
    
    public var online: Bool = false
    public var authorized: Bool {
        get {
            self.token != nil
        }
    }
}

// MARK: Setter

extension JellyfinClient {
    public func setServerUrl(_ serverUrl: String) throws {
        guard let serverUrl = URL(string: serverUrl) else {
            throw JellyfinClientError.invalidServerUrl
        }
        
        Self.defaults.set(serverUrl, forKey: "serverUrl")
        self.serverUrl = serverUrl
    }
    public func setToken(_ token: String) {
        Self.defaults.set(token, forKey: "token")
        self.token = token
    }
    public func setUserId(_ userId: String) {
        Self.defaults.set(userId, forKey: "userId")
        self.userId = userId
    }
    
    // this is a bad way of doing this, but it works
    public func logout() {
        Self.defaults.set(nil, forKey: "token")
        Self.defaults.set(nil, forKey: "userId")
        
        exit(0)
    }
}

// MARK: Singleton

extension JellyfinClient {
    public private(set) static var shared = {
        JellyfinClient(
            serverUrl: defaults.url(forKey: "serverUrl"),
            token: defaults.string(forKey: "token"),
            userId: defaults.string(forKey: "userId"))
    }()
}
