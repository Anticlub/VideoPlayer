//
//  PlayerService.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 5/3/26.
//

import AVFoundation

final class PlayerService {
    
    private(set) var player: AVPlayer?
    
    func load(url: URL) {
        player = AVPlayer(url: url)
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
}
