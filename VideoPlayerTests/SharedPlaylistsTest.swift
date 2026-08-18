//
//  SharedPlaylistsTest.swift
//  VideoPlayerTests
//
//  Created by cristofer fernandez on 16/8/26.
//

import Testing
@testable import VideoPlayer
import Foundation

// MARK: - Mock

final class MockPlaylistRepository: PlaylistRepositoryProtocol {
    var result: [PlaylistSource]

    init(result: [PlaylistSource] = []) {
        self.result = result
    }

    func fetchPlaylists() async throws -> [PlaylistSource] { result }
}

// MARK: - Tests

@Test @MainActor func loadRemotePlaylists_withRemote_replacesDefaults() async throws {
    let remote = [
        PlaylistSource(name: "Remota", url: try #require(URL(string: "https://r.com/a.m3u")), kind: .live)
    ]
    let vm = PlayerViewModel(
        playerService: MockPlayerService(),
        playlistRepository: MockPlaylistRepository(result: remote)
    )

    await vm.loadRemotePlaylists()

    #expect(vm.playlistSources.count == 1)
    #expect(vm.playlistSources.first?.name == "Remota")
    #expect(vm.selectedPlaylist?.name == "Remota")
}

@Test @MainActor func loadRemotePlaylists_whenEmpty_keepsDefaults() async {
    let vm = PlayerViewModel(
        playerService: MockPlayerService(),
        playlistRepository: MockPlaylistRepository(result: [])
    )
    let defaultsCount = vm.playlistSources.count

    await vm.loadRemotePlaylists()

    // Sin playlists remotas se mantienen las de demo.
    #expect(vm.playlistSources.count == defaultsCount)
    #expect(vm.playlistSources.count == 3)
}
