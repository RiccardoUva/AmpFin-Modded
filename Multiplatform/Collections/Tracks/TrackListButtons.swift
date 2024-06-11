//
//  TrackListButtons.swift
//  Music
//
//  Created by Rasmus Krämer on 06.09.23.
//

import SwiftUI

struct TrackListButtons: View {
    var background: Material = .ultraThickMaterial
    
    let startPlayback: (_ shuffle: Bool) -> ()
    
    var body: some View {
        LazyVGrid(columns: [.init(spacing: .innerSpacing), .init()]) {
            TrackListButton(icon: "play.fill", label: "queue.play", background: background) {
                startPlayback(false)
            }
            
            TrackListButton(icon: "shuffle", label: "queue.shuffle", background: background) {
                startPlayback(true)
            }
        }
    }
    
    struct TrackListButton : View {
        let icon: String
        let label: LocalizedStringKey
        
        let background: Material
        let callback: () -> Void
        
        var body: some View {
            ZStack {
                // This horrible abomination ensures that both buttons have the same height
                Label(String("TEXT"), systemImage: "shuffle")
                    .opacity(0)
                
                Label(label, systemImage: icon)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .contentShape(.hoverMenuInteraction, RoundedRectangle(cornerRadius: 7))
            .hoverEffect(.lift)
            .foregroundColor(.accentColor)
            .bold()
            .onTapGesture {
                callback()
            }
        }
    }
}

#Preview {
    TrackListButtons {
        print($0)
    }
}
