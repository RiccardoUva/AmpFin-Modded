//
//  AlbumGridItem.swift
//  Music
//
//  Created by Rasmus Krämer on 06.09.23.
//

import SwiftUI
import AFBase

struct AlbumCover: View {
    @Environment(\.redactionReasons) private var redactionReasons
    
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ItemImage(cover: album.cover)
            
            Group {
                Text(album.name)
                    .font(.subheadline)
                    .padding(.top, 7)
                    .padding(.bottom, 2)
                
                Text(album.artistName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 7)
            }
            .lineLimit(1)
        }
        .padding(.innerSpacing / 2)
        .contentShape(.hoverMenuInteraction, RoundedRectangle(cornerRadius: 7))
        .modifier(AlbumContextMenuModifier(album: album))
        .padding(.innerSpacing / -2)
    }
}

extension AlbumCover {
    static let placeholder: some View = AlbumCover(album: .init(
        id: "placeholder",
        name: "Placeholder",
        cover: nil,
        favorite: false,
        overview: nil,
        genres: [],
        releaseDate: nil,
        artists: [.init(id: "placeholder", name: "Placeholder")],
        playCount: 0,
        lastPlayed: nil)
    ).redacted(reason: .placeholder)
}

#Preview {
    AlbumCover.placeholder
}
