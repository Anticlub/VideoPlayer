//
//  PlayerService.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 5/3/26.
//

import AVFoundation

final class PlayerService {
    
    private(set) var player: AVPlayer?
    private var drmManager: DRMManager?
    
    func load(source: PlaybackSource) {
        let asset = AVURLAsset(url: source.url)
        
        if let drm = source.drm {
            print("PlayService: configuring DRM")
            configureDRM(for: asset, configuration: drm)
        } else {
            drmManager = nil
        }
        
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
    }
    
    func play() {
        player?.play() 
    }
    
    func pause() {
        player?.pause()
    }
    
    func togglePlayPause() {
        guard let player else { return }
        
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.play()
        }
    }
    
    func stop() {
        player?.pause()
        player = nil
    }
    
    private func configureDRM(for asset: AVURLAsset, configuration: DRMConfiguration) {
        let manager = DRMManager(configuration: configuration)
        manager.prepare(asset: asset)
        drmManager = manager
        print("PlayerService.configureDRM called")
    }
    
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        print("DRMManager: intercepted FairPlay request")
        
        guard let url = loadingRequest.request.url else {
            print("DRMManager: missing request URL")
            return false
        }
        
        print("DRMMangaer: resutest URL -> \(url.absoluteString)")
        return true
    }
}
