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

    init() {
        let fallback = [
            Channel(
                name: "Clan",
                url: URL(string: "https://rtvelivestream.rtve.es/rtvesec/clan/clan_main_dvr.m3u8")!)
        
        ]

        self.channels = fallback
        self.selectedChannel = fallback[0]
        self.url = fallback[0].url
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
    
    func loadPlaylist(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let text = String(data: data, encoding: .utf8) else { return }
            
            let parsed = M3UParser.parse(text)
            guard !parsed.isEmpty else {
                setError("No se encontraron canales en la playlist")
                return
            }
            
            let filtered = parsed.filter { ch in
                let s = ch.url.absoluteString.lowercased()
                return (ch.url.scheme == "https" || ch.url.scheme == "http") && s.contains(".m3u8")
            }
            guard !filtered.isEmpty else {
                setError("La playlist no contiene streams HLS (.m3u8) válidos.")
                return
            }
            
            channels = parsed
            selectedChannel = parsed[0]
            self.url = parsed[0].url
        } catch {
            setError("No se pudo cargar la playlist: \(error.localizedDescription)")
        }
    }
}
