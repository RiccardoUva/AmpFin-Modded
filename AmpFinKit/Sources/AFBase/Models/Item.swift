//
//  Item.swift
//  Music
//
//  Created by Rasmus Krämer on 06.09.23.
//

import Foundation
import OSLog

/// Superclass of all other item types
@Observable public class Item: Identifiable, Codable {
    /// Unique identifier of the item
    public let id: String
    /// Type of the item
    public let type: ItemType
    
    /// Name the item was released under
    public let name: String
    
    /// Cover associated with the item. Can belong to the item itself or the parent album
    public var cover: Cover?
    /// Affinity status of the user
    public var favorite: Bool
    
    init(id: String, type: ItemType, name: String, cover: Cover? = nil, favorite: Bool) {
        self.id = id
        self.type = type
        self.name = name
        self.cover = cover
        self.favorite = favorite
    }
    
    enum CodingKeys: CodingKey {
        case id
        case type
        case name
        case cover
        case favorite
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(ItemType.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        self.cover = try container.decodeIfPresent(Cover.self, forKey: .cover)
        self.favorite = try container.decode(Bool.self, forKey: .favorite)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.cover, forKey: .cover)
        try container.encode(self.favorite, forKey: .favorite)
    }
}

extension Item: Equatable {
    public static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: Util

extension Item {
    /// Type of an item
    public enum ItemType: Codable {
        case album
        case artist
        case track
        case playlist
    }
    
    /// Reduced version of the artist class
    public struct ReducedArtist: Codable {
        /// Unique identifier of the artist
        public let id: String
        /// Name of the artist
        public let name: String
        
        public init(id: String, name: String) {
            self.id = id
            self.name = name
        }
    }
    
    public static let affinityChanged = NSNotification.Name("io.rfk.ampfin.item.affinity")
}

// MARK: Computed

extension Item {
    /// Name that should be used to sort the item by
    public var sortName: String {
        var sortName = name.lowercased()
        
        if sortName.starts(with: "a ") {
            sortName = String(sortName.dropFirst(2))
        }
        if sortName.starts(with: "the ") {
            sortName = String(sortName.dropFirst(4))
        }
        
        return sortName
    }
}

// MARK: Cover

extension Item {
    /// Image associated with an item
    public final class Cover: Codable {
        /// Source of the image
        public let type: CoverType
        /// URL of the image
        public var url: URL
        
        public init(type: CoverType, url: URL) {
            self.type = type
            self.url = url
        }
        
        /// Source of an item image
        public enum CoverType: Codable, Hashable {
            case local
            case remote
            case mock
        }
    }
}
