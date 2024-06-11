//
//  NowPlaying.swift
//  Multiplatform
//
//  Created by Rasmus Krämer on 03.05.24.
//

import Foundation

struct NowPlaying {
    private init() {}
    
    enum Tab {
        case cover
        case lyrics
        case queue
    }
}

extension NowPlaying {
    static let widthChangeNotification = NSNotification.Name("io.rfk.ampfin.sidebar.width.changed")
    static let offsetChangeNotification = NSNotification.Name("io.rfk.ampfin.sidebar.offset.changed")
}
