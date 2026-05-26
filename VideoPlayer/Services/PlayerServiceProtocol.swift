//
//  PlayerServiceProtocol.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 18/5/26.
//

import Foundation
import AVFoundation
internal import Combine

protocol PlayerServiceProtocol {
    
    var player: AVPlayer? { get }
    var availableVariants: [AVAssetVariant] { get }
    var variantsPublisher: AnyPublisher<[AVAssetVariant], Never> { get }
    var currentPresentationSizePublisher: AnyPublisher<CGSize, Never> { get }
    
    func load(source: PlaybackSource)
    func play()
    func pause()
    func stop()
    func togglePlayPause()
    func selectVariant(_ variant: AVAssetVariant)
    
}
