//
//  FirebasePlaylistRepository.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 16/8/26.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

/// Lee las playlists del usuario desde la Realtime Database, del mismo proyecto Firebase
/// que la app Android. Esquema compartido: `users/{uid}/playlists/{id}` → `{ id, name, url, type }`.
/// Espejo de `FirebasePlaylistDataSourceImpl.downloadPlaylists()` en Android.
final class FirebasePlaylistRepository: PlaylistRepositoryProtocol {

    func fetchPlaylists() async throws -> [PlaylistSource] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        let ref = Database.database().reference()
            .child("users")
            .child(uid)
            .child("playlists")

        let snapshot = try await ref.getData()
        guard snapshot.exists() else { return [] }

        return snapshot.children.allObjects
            .compactMap { $0 as? DataSnapshot }
            .compactMap(Self.mapPlaylist)
    }

    /// El esquema remoto no distingue live/VOD, así que las playlists remotas (IPTV)
    /// entran como `.live`.
    private static func mapPlaylist(_ snapshot: DataSnapshot) -> PlaylistSource? {
        guard let dict = snapshot.value as? [String: Any],
              let name = dict["name"] as? String,
              let urlString = dict["url"] as? String,
              let url = URL(string: urlString) else {
            return nil
        }
        return PlaylistSource(name: name, url: url, kind: .live)
    }
}
