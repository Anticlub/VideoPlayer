//
//  PlayerViewModel.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 2/3/26.
//

import Foundation
import Combine

@MainActor
final class PlayerViewModel: ObservableObject {
    @Published var state: PlayerState

    // Lista de canales (por ahora mock)
    @Published private(set) var channels: [Channel]
    @Published private(set) var selectedChannel: Channel

    // URL actual que usa el PlayerView
    @Published private(set) var url: URL

    // Forzar a SwiftUI a recrear el player
    @Published private(set) var playerInstanceID = UUID()

    // INIT principal: arranca con una lista mock
    init() {
        let sample: [Channel] = [
            Channel(
                name: "TVE",
                url: URL(string: "https://ztnr.rtve.es/ztnr/1688877.m3u8")!
            ),
            Channel(
                name: "Clan",
                url: URL(string: "https://rtvelivestream.rtve.es/rtvesec/clan/clan_main_dvr.m3u8")!
            ),
            Channel(
                name: "Apple Basic",
                url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
            ),
            
        ]

        self.channels = sample
        self.selectedChannel = sample[0]
        self.url = sample[0].url
        self.state = .loading
    }

    // INIT de compatibilidad: si aún estás creando el VM con una URL desde ContentView
    convenience init(url: URL) {
        self.init(channels: [Channel(name: "Canal", url: url)], selectedIndex: 0)
    }

    // INIT útil si luego cargas canales desde fichero / red
    init(channels: [Channel], selectedIndex: Int = 0) {
        precondition(!channels.isEmpty, "channels no puede estar vacío")

        let index = max(0, min(selectedIndex, channels.count - 1))
        self.channels = channels
        self.selectedChannel = channels[index]
        self.url = channels[index].url
        self.state = .loading
    }

    func setLoading() { state = .loading }
    func setPlaying() { state = .playing }
    func setError(_ message: String) { state = .error(message) }

    func selectChannel(_ channel: Channel) {
        guard channel.id != selectedChannel.id else { return }
        
        selectedChannel = channel
        url = channel.url
        playerInstanceID = UUID()
    }

    func restartPlayer() {
        // Primero salimos del error para que el overlay desaparezca
        state = .loading
        // Luego recreamos el player
        playerInstanceID = UUID()
    }
}
