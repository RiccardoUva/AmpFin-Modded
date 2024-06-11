//
//  AlbumListRow.swift
//  Music
//
//  Created by Rasmus Krämer on 09.09.23.
//

import SwiftUI
import AFBase

struct AlbumListRow: View {
    let album: Album
    
    var body: some View {
        HStack(spacing: 0) {
            ItemImage(cover: album.cover)
                .frame(width: 45)
                .padding(.trailing, .connectedSpacing)
            
            VStack(alignment: .leading) {
                Text(album.name)
                    .lineLimit(1)
                    .font(.body)
                
                if album.artists.count > 0 {
                    Text(album.artistName)
                        .lineLimit(1)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 5)
            
            Spacer()
            
            DownloadIndicator(item: album)
        }
        .modifier(AlbumContextMenuModifier(album: album))
    }
}


#Preview {
    List {
        AlbumListRow(album: Album.fixture)
        AlbumListRow(album: Album.fixture)
        AlbumListRow(album: Album.fixture)
        AlbumListRow(album: Album.fixture)
        AlbumListRow(album: Album.fixture)
    }
    .listStyle(.plain)
}
