//
//  Channel.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 3/3/26.
//

import Foundation

struct Channel: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let url: URL
}
