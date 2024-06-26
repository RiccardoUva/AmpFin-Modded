//
//  tracks.swift
//  Music
//
//  Created by Rasmus Krämer on 06.09.23.
//

import SwiftUI
import Defaults
import AFBase
import AFPlayback

struct TracksView: View {
    @Default(.sortOrder) private var sortOrder
    @Default(.sortAscending) private var sortAscending
    @Environment(\.libraryDataProvider) private var dataProvider
    
    let favoritesOnly: Bool
    
    @State private var count = 0
    @State private var success = false
    @State private var failure = false
    @State private var tracks = [Track]()
    
    @State private var search: String = ""
    @State private var searchTask: Task<Void, Error>?
    
    var sortState: [String] {[
        search,
        sortOrder.rawValue,
        sortAscending.description,
    ]}
    
    var body: some View {
        VStack {
            if success {
                List {
                    TrackListButtons {
                        if $0 {
                            Task {
                                if let tracks = try? await dataProvider.getTracks(limit: 200, startIndex: 0, sortOrder: .random, ascending: false, favorite: false, search: nil).0 {
                                    AudioPlayer.current.startPlayback(tracks: tracks, startIndex: 0, shuffle: false, playbackInfo: .init(container: nil))
                                } else {
                                    AudioPlayer.current.startPlayback(tracks: tracks, startIndex: 0, shuffle: true, playbackInfo: .init(container: nil))
                                }
                            }
                        } else {
                            AudioPlayer.current.startPlayback(tracks: tracks, startIndex: 0, shuffle: false, playbackInfo: .init(container: nil))
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: .connectedSpacing, trailing: 0))
                    .padding(.horizontal, .outerSpacing)
                    
                    TrackList(tracks: tracks, container: nil, count: count, loadMore: { () async -> Void in await loadTracks(shouldReset: false) })
                        .padding(.horizontal, .outerSpacing)
                }
                .listStyle(.plain)
            } else if failure {
                ErrorView()
            } else {
                LoadingView()
            }
        }
        .navigationTitle(favoritesOnly ? "title.favorites" : "title.tracks")
        .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "search.tracks")
        .modifier(NowPlaying.SafeAreaModifier())
        .toolbar {
            SortSelector(ascending: $sortAscending, sortOrder: $sortOrder)
        }
        .task {
            if tracks.isEmpty {
                await loadTracks(shouldReset: false)
            }
        }
        .refreshable {
            await loadTracks(shouldReset: true)
        }
        .onChange(of: sortState) {
            searchTask?.cancel()
            searchTask = Task {
                try await Task.sleep(nanoseconds: UInt64(0.5 * TimeInterval(NSEC_PER_SEC)))
                await loadTracks(shouldReset: true)
                searchTask = nil
            }
        }
    }
}

// MARK: Helper

extension TracksView {
    func loadTracks(shouldReset: Bool) async {
        failure = false
        
        let search: String?
        
        if self.search.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            search = nil
        } else {
            search = self.search
        }
        
        if shouldReset {
            count = 0
            tracks = []
        }
        
        do {
            let result = try await dataProvider.getTracks(limit: 100, startIndex: tracks.count, sortOrder: sortOrder, ascending: sortAscending, favorite: favoritesOnly, search: search)
            
            count = result.1
            tracks += result.0
            
            success = true
        } catch {
            failure = true
        }
    }
}

#Preview {
    NavigationStack {
        TracksView(favoritesOnly: false)
    }
}

#Preview {
    NavigationStack {
        TracksView(favoritesOnly: true)
    }
}
