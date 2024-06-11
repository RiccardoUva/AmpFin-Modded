//
//  JellyfinClient+Items.swift
//  Music
//
//  Created by Rasmus Krämer on 06.09.23.
//

import Foundation

public extension JellyfinClient {
    // MARK: getAlbums
    
    /// Get selected albums from all libraries
    func getAlbums(limit: Int, startIndex: Int, sortOrder: ItemSortOrder, ascending: Bool, favorite: Bool, search: String?) async throws -> ([Album], Int) {
        var query = [
            URLQueryItem(name: "SortBy", value: sortOrder.rawValue),
            URLQueryItem(name: "SortOrder", value: ascending ? "Ascending" : "Descending"),
            URLQueryItem(name: "IncludeItemTypes", value: "MusicAlbum"),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "ImageTypeLimit", value: "1"),
            URLQueryItem(name: "EnableImageTypes", value: "Primary"),
            URLQueryItem(name: "Fields", value: "Genres,Overview,PremiereDate"),
        ]
        
        if limit > 0 {
            query.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        if startIndex > 0 {
            query.append(URLQueryItem(name: "startIndex", value: String(startIndex)))
        }
        if favorite {
            query.append(URLQueryItem(name: "Filters", value: "IsFavorite"))
        }
        if let search = search {
            query.append(URLQueryItem(name: "searchTerm", value: search))
        }
        
        let response = try await request(ClientRequest<AlbumItemsResponse>(path: "Items", method: "GET", query: query, userPrefix: true))
        return (
            response.Items.map(Album.convertFromJellyfin),
            response.TotalRecordCount
        )
    }
    
    /// Get all albums by the specified artist
    func getAlbums(limit: Int, startIndex: Int, artistId: String, sortOrder: ItemSortOrder, ascending: Bool) async throws -> ([Album], Int) {
        var query = [
            URLQueryItem(name: "SortBy", value: sortOrder.rawValue),
            URLQueryItem(name: "SortOrder", value: ascending ? "Ascending" : "Descending"),
            URLQueryItem(name: "IncludeItemTypes", value: "MusicAlbum"),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "ImageTypeLimit", value: "1"),
            URLQueryItem(name: "EnableImageTypes", value: "Primary"),
            URLQueryItem(name: "Fields", value: "Genres,Overview,PremiereDate"),
            URLQueryItem(name: "AlbumArtistIds", value: artistId)
        ]
        
        if limit > 0 {
            query.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        if startIndex > 0 {
            query.append(URLQueryItem(name: "startIndex", value: String(startIndex)))
        }
        
        let response = try await request(ClientRequest<AlbumItemsResponse>(path: "Items", method: "GET", query: query, userPrefix: true))
        
        return (
            response.Items.map(Album.convertFromJellyfin),
            response.TotalRecordCount
        )
    }
    
    /// Get albums (limited to 20) matching the query
    func getAlbums(query: String) async throws -> [Album] {
        let response = try await request(ClientRequest<AlbumItemsResponse>(path: "Items", method: "GET", query: [
            URLQueryItem(name: "searchTerm", value: query),
            URLQueryItem(name: "Limit", value: "20"),
            URLQueryItem(name: "IncludeItemTypes", value: "MusicAlbum"),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "ImageTypeLimit", value: "1"),
            URLQueryItem(name: "EnableImageTypes", value: "Primary"),
            URLQueryItem(name: "Fields", value: "Genres,Overview,PremiereDate,AlbumArtists,People"),
        ], userPrefix: true))
        
        return response.Items.map(Album.convertFromJellyfin)
    }
    
    /// Get random albums
    func getAlbums(limit: Int) async throws -> [Album] {
        let response = try await request(ClientRequest<AlbumItemsResponse>(path: "Items", method: "GET", query: [
            URLQueryItem(name: "SortBy", value: "IsFavoriteOrLiked,Random"),
            URLQueryItem(name: "IncludeItemTypes", value: "MusicAlbum"),
            URLQueryItem(name: "Limit", value: String(limit)),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "ImageTypeLimit", value: "1"),
            URLQueryItem(name: "EnableImageTypes", value: "Primary"),
            URLQueryItem(name: "Fields", value: "Genres,Overview,PremiereDate"),
        ], userPrefix: true))
        
        return response.Items.map(Album.convertFromJellyfin)
    }
    
    /// Get similar items
    func getAlbums(similarToAlbumId: String) async throws -> [Album] {
        let response = try await request(ClientRequest<AlbumItemsResponse>(path: "Items/\(similarToAlbumId)/Similar", method: "GET", query: [
            URLQueryItem(name: "Fields", value: "Genres,Overview,PremiereDate"),
            URLQueryItem(name: "limit", value: String(10)),
        ], userId: true))
        
        return response.Items.map(Album.convertFromJellyfin)
    }
    
    // MARK: Other
    
    /// Get an album by its ID
    func getAlbum(albumId: String) async throws -> Album {
        if let album = try await request(ClientRequest<JellyfinAlbum?>(path: "Items/\(albumId)", method: "GET", query: [
            URLQueryItem(name: "IncludeItemTypes", value: "MusicAlbum"),
            URLQueryItem(name: "Recursive", value: "true"),
            URLQueryItem(name: "ImageTypeLimit", value: "1"),
            URLQueryItem(name: "EnableImageTypes", value: "Primary"),
            URLQueryItem(name: "Fields", value: "Genres,Overview,PremiereDate"),
        ], userPrefix: true)) {
            return Album.convertFromJellyfin(album)
        }
        
        throw JellyfinClientError.invalidResponse
    }
}
