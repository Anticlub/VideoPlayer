//
//  PlaylistSource.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 4/3/26.
//

import Foundation

struct PlaylistSource: Identifiable, Equatable {
    
    let id = UUID()
    let name: String
    let url: URL
    let kind: Kind
    
    enum Kind: String {
        case live = "Live"
        case vod = "VOD"
    }
}
