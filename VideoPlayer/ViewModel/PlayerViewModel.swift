//
//  PlayerViewModel.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 2/3/26.
//

import Foundation
internal import Combine
import AVFoundation


@MainActor
final class PlayerViewModel: ObservableObject {
    private let playerService = PlayerService()
    
    var player: AVPlayer? {
        playerService.player
    }
    @Published var state: PlayerState
    
    @Published private(set) var playlistSources: [PlaylistSource]
    @Published private(set) var selectedPlaylist: PlaylistSource?

    @Published private(set) var channels: [Channel]
    @Published private(set) var selectedChannel: Channel

    @Published private(set) var playerInstanceID = UUID()

    init() {
        let sources: [PlaylistSource] = [
            PlaylistSource(
                name: "España (Live)",
                url: URL(string: "https://www.tdtchannels.com/lists/tv_mpd.m3u8")!,
                kind: .live
            ),
            PlaylistSource(
                name: "Axinom DRM Clear",
                url: URL(string: "https://media.axprod.net/TestVectors/v9-MultiFormat/Clear/Manifest_1080p.m3u8")!,
                kind: .vod
            ),
            PlaylistSource(
                name: "Axinom DRM Test",
                url: URL(string: "https://media.axprod.net/TestVectors/v9-MultiFormat/Encrypted_Cbcs/Manifest_1080p.m3u8")!,
                kind: .vod
            ),
            
        
        ]

        self.playlistSources = sources
        self.selectedPlaylist = sources.first
        
        let fallbackChannel = Channel(
            name: "Apple BipBop",
            url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevca/master.m3u8")!,
            drmConfiguration: nil
        )
        
        self.channels = [fallbackChannel]
        self.selectedChannel = fallbackChannel
        self.state = .loading
    }

    func setLoading() { state = .loading }
    func setPlaying() { state = .playing }
    func setError(_ message: String) { state = .error(message) }

    func selectChannel(_ channel: Channel) {
        if channel.id == selectedChannel.id, player != nil {
            return
        }

        selectedChannel = channel
        
        let source = PlaybackSource(
            url: channel.url,
            drm: channel.drmConfiguration
        )

//        print("PlayerService.load -> url: \(source.url.absoluteString)")
//        print("PlayerService.load -> drm: \(String(describing: source.drm))")
        playerService.load(source: source)
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
        } catch {
            setError("No se pudo cargar la playlist: \(error.localizedDescription)")
        }
    }
    
    func selectPlaylist(_ source: PlaylistSource) async {
        selectedPlaylist = source

        if isDirectPlaybackSource(source.url) {
            let drmConfiguration: DRMConfiguration?

            if source.name == "Axinom FairPlay Test" {
                drmConfiguration = DRMConfiguration(
                    certificateURL: URL(string: "https://drm-fairplay-licensing.axprod.net/AcquireLicense")!,
                    licenseURL: URL(string: "https://drm-fairplay-licensing.axprod.net/AcquireLicense")!
                )
            } else {
                drmConfiguration = nil
            }

            let directChannel = Channel(
                name: source.name,
                url: source.url,
                drmConfiguration: drmConfiguration
            )

            channels = [directChannel]
            selectedChannel = directChannel
            selectChannel(directChannel)
            return
        }

        await loadPlaylist(from: source.url)
    }
    
    func playPause() {
        playerService.togglePlayPause()
    }
    
    
    func nextChannel() {
        guard let idx = channels.firstIndex(where: { $0.id == selectedChannel.id}) else { return }
        let nextIndex = min(idx + 1, channels.count - 1)
        selectChannel(channels[nextIndex])
    }
    
    func previousChannel() {
        guard let idx = channels.firstIndex(where: { $0.id == selectedChannel.id}) else { return }
        let prevIndex = max(idx - 1, 0)
        selectChannel(channels[prevIndex])
    }
    
    func stop() {
        playerService.stop()
    }
    
    private func isDirectPlaybackSource(_ url: URL) -> Bool {
        let lastPath = url.lastPathComponent.lowercased()
        return lastPath.contains("manifest")
            || lastPath.contains("playlist")
            || lastPath.contains("index")
    }
}
