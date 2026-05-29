//
//  MockPlayerService.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 18/5/26.
//

import Combine
@testable import VideoPlayer
import AVFoundation

class MockPlayerService : PlayerServiceProtocol {
    var player: AVPlayer? = nil
    var loadWasCalled = false
    var stopWasCalled = false
    var togglePlayPauseWasCalled = false
    var availableVariants: [AVAssetVariant] = []
    var variantsPublisher: AnyPublisher<[AVAssetVariant], Never> {
        Just([]).eraseToAnyPublisher()
    }
    var currentPresentationSizePublisher: AnyPublisher<CGSize, Never>{
        Just(.zero).eraseToAnyPublisher()
    }
    func selectVariant(_ variant: AVAssetVariant) { }
    
    func load(source: PlaybackSource) {
        loadWasCalled = true
    }
    
    func play() {
        
    }
    
    func pause() {

    }
    
    func stop() {
        stopWasCalled = true
    }
    
    func togglePlayPause() {
        togglePlayPauseWasCalled = true
    }
    
    
}
