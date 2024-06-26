//
//  NavigationRoot.swift
//  Music
//
//  Created by Rasmus Krämer on 06.09.23.
//

import SwiftUI
import Defaults
import AFBase
import AFOffline

struct Tabs: View {
    @Default(.lastActiveTab) private var activeTab
    
    @State var libraryPath = NavigationPath()
    @State var downloadsPath = NavigationPath()
    
    var body: some View {
        TabView(selection: $activeTab) {
            Group {
                // MARK: Library
                
                NavigationStack(path: $libraryPath) {
                    LibraryView()
                        .modifier(Navigation.DestinationModifier())
                }
                .environment(\.libraryDataProvider, OnlineLibraryDataProvider())
                .onReceive(NotificationCenter.default.publisher(for: Navigation.navigateNotification)) { notification in
                    if let albumId = notification.userInfo?["albumId"] as? String {
                        libraryPath.append(Navigation.AlbumLoadDestination(albumId: albumId))
                    } else if let artistId = notification.userInfo?["artistId"] as? String {
                        libraryPath.append(Navigation.ArtistLoadDestination(artistId: artistId))
                    } else if let playlistId = notification.userInfo?["playlistId"] as? String {
                        libraryPath.append(Navigation.PlaylistLoadDestination(playlistId: playlistId))
                    }
                }
                .tag(Selection.library)
                .tabItem {
                    Label("tab.libarary", systemImage: "rectangle.stack.fill")
                }
                
                // MARK: Downloads
                
                NavigationStack(path: $downloadsPath) {
                    LibraryView()
                        .modifier(Navigation.DestinationModifier())
                }
                .environment(\.libraryDataProvider, OfflineLibraryDataProvider())
                .onReceive(NotificationCenter.default.publisher(for: Navigation.navigateNotification)) { notification in
                    if let albumId = notification.userInfo?["offlineAlbumId"] as? String {
                        downloadsPath.append(Navigation.AlbumLoadDestination(albumId: albumId))
                    }
                    if let albumId = notification.userInfo?["offlinePlaylistId"] as? String {
                        downloadsPath.append(Navigation.AlbumLoadDestination(albumId: albumId))
                    }
                }
                .tag(Selection.downloads)
                .tabItem {
                    Label("tab.downloads", systemImage: "arrow.down")
                }
                
                // MARK: Search
                
                SearchView()
                    .tag(Selection.search)
                    .tabItem {
                        Label("tab.search", systemImage: "magnifyingglass")
                    }
            }
            .modifier(NowPlaying.CompactBarModifier())
        }
        .modifier(NowPlaying.CompactViewModifier())
        .modifier(Navigation.NotificationModifier(
            navigateAlbum: {
                if OfflineManager.shared.isAlbumDownloaded(albumId: $0) {
                    activeTab = .downloads
                    
                    NotificationCenter.default.post(name: Navigation.navigateNotification, object: nil, userInfo: [
                        "offlineAlbumId": $0,
                    ])
                } else {
                    activeTab = .library
                    
                    NotificationCenter.default.post(name: Navigation.navigateNotification, object: nil, userInfo: [
                        "albumId": $0
                    ])
                }
            }, navigateArtist: {
                activeTab = .library
                
                NotificationCenter.default.post(name: Navigation.navigateNotification, object: nil, userInfo: [
                    "artistId": $0,
                ])
            }, navigatePlaylist: {
                if OfflineManager.shared.isPlaylistDownloaded(playlistId: $0) {
                    activeTab = .downloads
                    
                    NotificationCenter.default.post(name: Navigation.navigateNotification, object: nil, userInfo: [
                        "offlinePlaylistId": $0,
                    ])
                } else {
                    activeTab = .library
                    
                    NotificationCenter.default.post(name: Navigation.navigateNotification, object: nil, userInfo: [
                        "playlistId": $0,
                    ])
                }
            }))
    }
}

extension Tabs {
    enum Selection: Int, Defaults.Serializable {
        case library = 0
        case downloads = 1
        case search = 2
    }
}

#Preview {
    Tabs()
}
