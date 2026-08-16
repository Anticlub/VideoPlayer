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
    var availableVariants: [AVAssetVariant] { get }
    var currentPresentationSize: CGSize { get }

    func load(source: PlaybackSource)
    func play()
    func pause()
    func stop()
    func togglePlayPause()
    func selectVariant(_ variant: AVAssetVariant)

}
