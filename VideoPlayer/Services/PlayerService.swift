//
//  PlayerService.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 5/3/26.
//

import AVFoundation
import os

private let logger = Logger(subsystem: "VideoPlayer", category: "PlayerService")

final class PlayerService : PlayerServiceProtocol {
    private(set) var availableVariants: [AVAssetVariant] = []
    private(set) var player: AVPlayer?
    private var drmManager: DRMManager?
    
    func load(source: PlaybackSource) {
        logger.info("Loading playback source")
        let asset = AVURLAsset(url: source.url)
        
        if let drm = source.drm {
            logger.info("DRM configuration detected")
            configureDRM(for: asset, configuration: drm)
        } else {
            drmManager = nil
        }
        
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        
        Task {
            do {
                let variants = try await asset.load(.variants)
                await MainActor.run {
                    self.availableVariants = variants
                }
            } catch {
                logger.error("Failed to load variants: \(error.localizedDescription)")
            }
        }
    }
    
    func play() {
        logger.debug("Play")
        player?.play()
    }
    
    func pause() {
        logger.debug("Pause")
        player?.pause()
    }
    
    func togglePlayPause() {
        guard let player else { return }
        
        if player.timeControlStatus == .playing {
            logger.debug("Toggle -> pause")
            player.pause()
        } else {
            logger.debug("Toggle -> play")
            player.play()
        }
    }
    
    func stop() {
        logger.info("Stop playback")
        player?.pause()
        player = nil
        drmManager = nil
    }
    
    private func configureDRM(for asset: AVURLAsset, configuration: DRMConfiguration) {
        logger.info("Configuring FairPlay DRM")

        let manager = DRMManager(configuration: configuration)
        manager.prepare(asset: asset)
        drmManager = manager
    }
    
    func selectVariant(_ variant: AVAssetVariant) {
        guard let item = player?.currentItem else { return }
        guard let bitRate = variant.averageBitRate else { return }
        item.preferredPeakBitRate = bitRate
        
    }
}
