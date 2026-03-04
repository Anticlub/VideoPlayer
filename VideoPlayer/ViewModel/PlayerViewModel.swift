//
//  PlayerViewModel.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 2/3/26.
//

import Foundation

@MainActor
final class PlayerViewModel: ObservableObject {
    @Published var state: PlayerState
    
    @Published private(set) var playlistSources: [PlaylistSource]
    @Published private(set) var selectedPlaylist: PlaylistSource?

    // Lista de canales (por ahora mock)
    @Published private(set) var channels: [Channel]
    @Published private(set) var selectedChannel: Channel

    // URL actual que usa el PlayerView
    @Published private(set) var url: URL

    // Forzar a SwiftUI a recrear el player
    @Published private(set) var playerInstanceID = UUID()

    init() {
        let sources: [PlaylistSource] = [
            PlaylistSource(
                name: "España (Live)",
                url: URL(string: "https://www.m3u.cl/lista/ES.m3u")!,
                kind: .live
            ),
        
        ]

        self.playlistSources = sources
        self.selectedPlaylist = sources.first
        
        let fallbackChannel = Channel(
            name: "Apple BipBop",
            url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevca/master.m3u8")!
        )
        
        self.channels = [fallbackChannel]
        self.selectedChannel = fallbackChannel
        self.url = fallbackChannel.url
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

    
    func loadPlaylist(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let text = String(data: data, encoding: .utf8) else { return }
            
            let parsed = M3UParser.parse(text)
            guard !parsed.isEmpty else {
                setError("No se encontraron canales en la playlist")
                return
            }
            
            channels = parsed
            selectedChannel = parsed[0]
            self.url = parsed[0].url
        } catch {
            setError("No se pudo cargar la playlist: \(error.localizedDescription)")
        }
    }
    
    func selectPlaylist(_ source: PlaylistSource) async {
        selectedPlaylist = source
        await loadPlaylist(from: source.url)
    }
    
}
