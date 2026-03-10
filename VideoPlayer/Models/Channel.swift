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
    let logoURL: URL?
    let groupTitle: String?
    let drmConfiguration: DRMConfiguration?
    
    init(
        name: String,
        url: URL,
        logoURL: URL? = nil,
        groupTitle: String? = nil,
        drmConfiguration: DRMConfiguration? = nil
    ) {
        self.name = name
        self.url = url
        self.logoURL = logoURL
        self.groupTitle = groupTitle
        self.drmConfiguration = drmConfiguration
    }
}
