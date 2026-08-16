//
//  PlayerViewModel.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 2/3/26.
//

import Foundation
import Observation
import AVFoundation


@Observable
@MainActor
final class PlayerViewModel {
    private let playerService : PlayerServiceProtocol

    var player: AVPlayer? {
        playerService.player
    }
    var state: PlayerState

    private(set) var playlistSources: [PlaylistSource]
    private(set) var selectedPlaylist: PlaylistSource?

    private(set) var channels: [Channel]
    private(set) var selectedChannel: Channel
    private(set) var playingChannel: Channel?

    private(set) var playerInstanceID = UUID()
    private(set) var selectedVariant: VideoVariant?

    /// Variantes de calidad, derivadas del servicio (observable) y mapeadas a `VideoVariant`.
    var availableVariants: [VideoVariant] {
        playerService.availableVariants.map { VideoVariant(variant: $0) }
    }

    /// Tamaño de presentación actual, expuesto por el servicio observable.
    var currentPresentationSize: CGSize {
        playerService.currentPresentationSize
    }

    var uniqueVariantsByHeight: [VideoVariant] {
        var seenHeights = Set<Int>()
        return availableVariants
            .sorted { a, b in
                a.bitRate > b.bitRate
            }
            .filter { variant in
                seenHeights.insert(variant.height).inserted
            }
            .sorted { a, b in
                a.height > b.height
            }
    }
    
    var currentQuality: String {
        let height = currentPresentationSize.height
        if height == 0 {
            return "Auto"
        } else {
            return "\(Int(height))p"
        }
    }

    init(playerService: PlayerServiceProtocol, initialChannels: [Channel]? = nil) {
        self.playerService = playerService
        let sources: [PlaylistSource] = [
            PlaylistSource(
                name: "España (Live)",
                url: Constants.Streams.tdtSpain,
                kind: .live
            ),
            PlaylistSource(
                name: "Apple",
                url: Constants.Streams.bipBop,
                kind: .vod
            ),
            PlaylistSource(
                name: "Dibujos",
                url: Constants.Streams.dibujos,
                kind: .vod
            ),
            
        
        ]

        self.playlistSources = sources
        self.selectedPlaylist = sources.first
        
        let fallbackChannel = Channel(
            name: "Apple BipBop",
            url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevca/master.m3u8")!
        )

        let resolvedChannels = initialChannels ?? [fallbackChannel]
        self.channels = resolvedChannels
        self.selectedChannel = resolvedChannels.first ?? fallbackChannel
        self.state = .loading
    }
    
    func setLoading() { state = .loading }
    func setPlaying() { state = .playing }
    func setError(_ message: String) { state = .error(message) }
    func setIdle () { state = .idle }

    func selectChannel(_ channel: Channel) {
        if channel.id == playingChannel?.id, player != nil {
            return
        }

        selectedChannel = channel
        
        let source = PlaybackSource(
            url: channel.url,
            drm: channel.drmConfiguration
        )

        playerService.load(source: source)
        playerInstanceID = UUID()
        playingChannel = channel
    }
    
    func updateSelectedChannel(_ channel: Channel) {
        selectedChannel = channel
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
            updateSelectedChannel(channels[0])

        } catch {
            setError("No se pudo cargar la playlist: \(error.localizedDescription)")
        }
    }
    
    func loadInitialPlaylist() async {
        guard let initialSource = selectedPlaylist else { return }
        await loadPlaylist(from: initialSource.url)
    }
    
    func selectPlaylist(_ source: PlaylistSource) async {
        selectedPlaylist = source

        if isDirectPlaybackSource(source.url) {
            let directChannel = makeDirectChannel(from: source)

            channels = [directChannel]
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
    
    private func drmConfiguration(for source: PlaylistSource) -> DRMConfiguration? {
        
        if source.name == "Axinom DRM Test" {
            return DRMConfiguration(
                certificateURL: URL(string: "https://fps.ezdrm.com/demo/video/ezdrm.cer")!,
                licenseURL: URL(string: "https://fps.ezdrm.com/demo/video/ezdrm")!
            )
        }
        
        return nil
    }
    
    private func makeDirectChannel(from source: PlaylistSource) -> Channel {
        Channel(
            name: source.name,
            url: source.url,
            drmConfiguration: drmConfiguration(for: source)
        )
    }
    
    private func makeFairPlayTestChannel() -> Channel {
        Channel(
            name: "EZDRM FairPlay Test",
            url: URL(string: "https://fps.ezdrm.com/demo/video/ezdrm.m3u8")!,
            drmConfiguration: DRMConfiguration(
                certificateURL: URL(string: "https://fps.ezdrm.com/demo/video/ezdrm.cer")!,
                licenseURL: URL(string: "https://fps.ezdrm.com/demo/video/ezdrm")!,
                headers: [:],
                queryItems: [],
                contentIdentifierOverride: nil
            )
        )
    }
    
    private func isDirectPlaybackSource(_ url: URL) -> Bool {
        let lastPath = url.lastPathComponent.lowercased()
        return lastPath.contains("manifest")
            || lastPath.contains("playlist")
            || lastPath.contains("index")
            || lastPath.contains("master")
            || lastPath.contains("main")
    }
    
    func selectVariant(_ variant: VideoVariant){
        selectedVariant = variant
        playerService.selectVariant(variant.variant)
    }
}
