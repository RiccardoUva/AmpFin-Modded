//
//  JellyfinClient+Other.swift
//  Music
//
//  Created by Rasmus Krämer on 06.09.23.
//

import Foundation

extension JellyfinClient {
    struct UserData: Codable {
        let PlayCount: Int
        let IsFavorite: Bool
        let LastPlayedDate: String?
    }
    
    struct JellyfinArtist: Codable {
        let Id: String
        let Name: String
    }
    
    struct ImageTags: Codable {
        let Primary: String?
    }
    
    struct LyricsResponse: Codable {
        let Lyrics: [Line]
        
        struct Line: Codable {
            let Start: Int64
            let Text: String
        }
    }
}

extension JellyfinClient {
    struct PublicServerInfoResponse: Codable {
        let LocalAddress: String
        let ServerName: String
        let Version: String
        let ProductName: String
        let OperatingSystem: String
        let Id: String
        let StartupWizardCompleted: Bool
    }
    
    struct AuthenticateByNameResponse: Codable {
        let AccessToken: String
        let User: User
        
        struct User: Codable {
            let Id: String
        }
    }
    
    struct UserDataResponse: Codable {
        let Name: String
        let ServerId: String
        let Id: String
        let HasPassword: Bool
    }
    
    public struct JellyfinSession: Codable {
        let Id: String
        let Client: String
        
        let DeviceId: String
        let DeviceName: String
        
        let PlayState: JellyfinPlayState
        let Capabilities: JellyfinCapabilities
        
        let NowPlayingItem: JellyfinTrackItem?
        // let NowPlayingQueueFullItems: [JellyfinTrackItem]
        
        struct JellyfinPlayState: Codable {
            let PositionTicks: Int64?
            let CanSeek: Bool
            let IsPaused: Bool
            let IsMuted: Bool
            let VolumeLevel: Int?
            let RepeatMode: String
            // only available in 10.9
            let PlaybackOrder: String?
        }
        struct JellyfinCapabilities: Codable {
            let PlayableMediaTypes: [String]
            let SupportedCommands: [String]
            let SupportsMediaControl: Bool
        }
    }
}

extension JellyfinClient {
    public enum PlayStateCommand: String {
        case play = "Unpause"
        case pause = "Pause"
        case next = "NextTrack"
        case previous = "PreviousTrack"
        case stop = "Stop"
    }
    
    // this is truly stupid. there are more commands but these are the only ones that are actually used
    public enum PlayCommand: String {
        case next = "PlayNext"
        case last = "PlayLast"
    }
}
