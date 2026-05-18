//
//  PlayerServiceProtocol.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 18/5/26.
//

import Foundation
import AVFoundation

protocol PlayerServiceProtocol {
    
    var player: AVPlayer? { get }
    
    func load(source: PlaybackSource)
    func play()
    func pause()
    func stop()
    func togglePlayPause()
    
}
