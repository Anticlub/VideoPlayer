//
//  DRMConfiguration.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 9/3/26.
//

import Foundation

struct DRMConfiguration: Equatable {
    let certificateURL: URL
    let licenseURL: URL
    let headers: [String: String]
    let queryItems: [URLQueryItem]
    let contentIdentifierOverride: String?

    init(
        certificateURL: URL,
        licenseURL: URL,
        headers: [String: String] = [:],
        queryItems: [URLQueryItem] = [],
        contentIdentifierOverride: String? = nil
    ) {
        self.certificateURL = certificateURL
        self.licenseURL = licenseURL
        self.headers = headers
        self.queryItems = queryItems
        self.contentIdentifierOverride = contentIdentifierOverride
    }
}
