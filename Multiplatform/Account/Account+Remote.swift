//
//  Account+Remote.swift
//  Multiplatform
//
//  Created by Rasmus Krämer on 06.05.24.
//

import SwiftUI
import AFBase
import AFPlayback

extension AccountSheet {
    struct Remote: View {
        @State private var sessions: [Session]? = nil
        
        var body: some View {
            Section("account.remote") {
                if JellyfinWebSocket.shared.isConnected {
                    if AudioPlayer.current.source == .jellyfinRemote {
                        Button(role: .destructive) {
                            AudioPlayer.current.destroy()
                        } label: {
                            Label("remote.disconnect", systemImage: "network.slash")
                        }
                        .foregroundStyle(.red)
                    } else if let sessions = sessions {
                        if sessions.count == 0 {
                            Label("account.remote.empty", systemImage: "network.slash")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(sessions) { session in
                                Button {
                                    AudioPlayer.current.startRemoteControl(session: session)
                                } label: {
                                    VStack(alignment: .leading, spacing: 7) {
                                        Text(verbatim: "\(session.name) • \(session.client)")
                                        
                                        if let nowPlaying = session.nowPlaying {
                                            HStack {
                                                Image(systemName: "waveform")
                                                    .symbolEffect(.pulse.byLayer)
                                                
                                                Text(nowPlaying.name)
                                                
                                                Spacer()
                                            }
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        Label("account.remote.loading", systemImage: "network")
                            .foregroundStyle(.secondary)
                            .task {
                                sessions = await JellyfinClient.shared.getControllableSessions()
                            }
                    }
                } else {
                    Button {
                        JellyfinWebSocket.shared.connect()
                    } label: {
                        Label("remote.connect", systemImage: "network")
                    }
                    .foregroundStyle(.primary)
                }
            }
            .popoverTip(RemoteTip())
        }
    }
}
