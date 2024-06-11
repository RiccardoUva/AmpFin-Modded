//
//  File.swift
//  
//
//  Created by Rasmus Krämer on 23.02.24.
//

import Foundation
import AFBase

extension AudioPlayer {
    func setupObservers() {
        NotificationCenter.default.addObserver(forName: JellyfinWebSocket.disconnectedNotification, object: nil, queue: nil) { [self] _ in
            if source == .jellyfinRemote {
                destroy()
            }
        }
        
        NotificationCenter.default.addObserver(forName: Item.affinityChanged, object: nil, queue: nil) { [self] event in
            updateCommandCenter(favorite: event.userInfo?["favorite"] as? Bool ?? false)
        }
        
        // For some reason queue & repeat mode don't work
        // TODO: GeneralCommand/SetVolume
        
        NotificationCenter.default.addObserver(forName: JellyfinWebSocket.playStateCommandIssuedNotification, object: nil, queue: nil) { [self] notification in
            let command = notification.userInfo?["command"] as? String
            
            if command == "stop" {
                stopPlayback()
            } else if command == "playpause" {
                playing = !playing
            } else if command == "previoustrack" {
                backToPreviousItem()
            } else if command == "nexttrack" {
                advanceToNextTrack()
            } else if command == "seek" {
                let position = notification.userInfo?["position"] as? UInt64 ?? 0
                currentTime = Double(position / 10_000_000)
            } else if command == "repeatMode" {
                let mode = notification.userInfo?["repeatMode"] as? String
                repeatMode = mode == "RepeatAll" ? .queue : mode == "RepeatNone" ? .none : .track
            } else if command == "shuffleMode" {
                shuffled = notification.userInfo?["shuffleMode"] as? String == "Shuffle"
            }
        }
        
        NotificationCenter.default.addObserver(forName: JellyfinWebSocket.playCommandIssuedNotification, object: nil, queue: nil) { [self] notification in
            let command = notification.userInfo?["command"] as? String
            let trackIds = notification.userInfo?["trackIds"] as? [String]
            let index = notification.userInfo?["index"] as? Int ?? 0
            
            Task.detached { [self] in
                guard let tracks = await trackIds?.parallelMap(JellyfinClient.shared.getTrack).filter({ $0 != nil }) as? [Track], !tracks.isEmpty else { return }
                
                if command == "playnow" {
                    startPlayback(tracks: tracks, startIndex: index, shuffle: false, playbackInfo: .init(container: nil))
                } else if command == "playnext" {
                    queueTracks(tracks, index: 0, playbackInfo: .init(container: nil))
                } else if command == "playlast" {
                    queueTracks(tracks, index: queue.count, playbackInfo: .init(container: nil))
                }
            }
        }
    }
}
