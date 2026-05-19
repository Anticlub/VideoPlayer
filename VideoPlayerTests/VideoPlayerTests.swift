//
//  VideoPlayerTests.swift
//  VideoPlayerTests
//
//  Created by cristofer fernandez on 2/3/26.
//

import Testing
@testable import VideoPlayer
import Foundation

@Test @MainActor func selectChannel_shouldCallLoad() throws {
    let mock = MockPlayerService()
    let player = PlayerViewModel(playerService: mock)
    let url = Foundation.URL(string: "https://test.com")
    let channel = Channel(name: "Test", url: url!)
    player.selectChannel(channel)
    #expect(mock.loadWasCalled == true)
    
}

@Test @MainActor func stop_shouldCallStop() throws {
    let mock = MockPlayerService()
    let player = PlayerViewModel(playerService: mock)
    player.stop()
    #expect(mock.stopWasCalled == true)
}

@Test @MainActor func playPause_shouldCallTogglePlayPause() throws {
    let mock = MockPlayerService()
    let player = PlayerViewModel(playerService: mock)
    player.playPause()
    #expect(mock.togglePlayPauseWasCalled == true)
}

// TODO: testear nextChannel y previousChannel una vez que se refactorice PlayerViewModel para permitir inyectar canales
@Test @MainActor func nextChannel_shouldSelectNextChannel() throws {
    let mock = MockPlayerService()
    let channel1 = Channel(name: "Canal 1", url: Foundation.URL(string: "https://test1.com")!)
    let channel2 = Channel(name: "Canal 2", url: Foundation.URL(string: "https://test2.com")!)
    let player = PlayerViewModel(playerService: mock, initialChannels: [channel1, channel2])
    player.nextChannel()
    #expect(player.selectedChannel.name == "Canal 2")
}

@Test @MainActor func previousChannel_shouldSelectPreviousChannel() throws {
    let mock = MockPlayerService()
    let channel1 = Channel(name: "Canal 1", url: Foundation.URL(string: "https://test1.com")!)
    let channel2 = Channel(name: "Canal 2", url: Foundation.URL(string: "https://test2.com")!)
    let player = PlayerViewModel(playerService: mock, initialChannels: [channel1, channel2])
    player.nextChannel()
    #expect(player.selectedChannel.name == "Canal 2")
    player.previousChannel()
    #expect(player.selectedChannel.name == "Canal 1")
}
