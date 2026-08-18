//
//  PlaylistRepositoryProtocol.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 16/8/26.
//

import Foundation

/// Fuente de las playlists del usuario. Equivalente a `PlaylistRemoteDataSource` de Android.
protocol PlaylistRepositoryProtocol {
    /// Playlists del usuario autenticado. Devuelve `[]` si no hay sesión (p. ej. en tvOS).
    func fetchPlaylists() async throws -> [PlaylistSource]
}
