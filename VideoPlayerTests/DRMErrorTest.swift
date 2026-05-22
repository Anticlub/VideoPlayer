//
//  Untitled.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 22/05/2026.
//

import Testing
@testable import VideoPlayer
import Foundation

@Test @MainActor func drmError_certificateFetchFailed_shouldContainStatusCode() {
    let error = DRMManager.DRMError.certificateFetchFailed(statusCode: 404)
    
    if case .certificateFetchFailed(let statusCode) = error {
        #expect(statusCode == 404)
    } else {
        Issue.record("Expected certificateFetchFailed")
    }
}

@Test @MainActor func drmError_licenseRequestFailed_shouldContainStatusCode() {
    let error = DRMManager.DRMError.licenseRequestFailed(statusCode: 403)
    
    if case .licenseRequestFailed(let statusCode) = error {
        #expect(statusCode == 403)
    } else {
        Issue.record("Expected licenseRequestFailed")
    }
}
