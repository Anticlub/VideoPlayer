//
//  MockPlayerService.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 18/5/26.
//

@testable import VideoPlayer
import AVFoundation

class MockPlayerService : PlayerServiceProtocol {
    var player: AVPlayer? = nil
    var loadWasCalled = false
    var stopWasCalled = false
    var togglePlayPauseWasCalled = false
    
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
