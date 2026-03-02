//
//  PlayerState.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 2/3/26.
//

import Foundation

enum PlayerState : Equatable {
    case playing
    //case paused
    //case stopped
    case loading
    case error(String)
}
