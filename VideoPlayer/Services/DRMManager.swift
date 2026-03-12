//
//  DRMManager.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 9/3/26.
//

import AVFoundation
import os

private let logger = Logger(subsystem: "VideoPlayer", category: "DRM")

final class DRMManager: NSObject, AVAssetResourceLoaderDelegate {
    
    enum DRMError: Error {
        case invalidContentIdentifier
        case invalidLicenseURL
    }
    
    private let configuration: DRMConfiguration
    
    init(configuration: DRMConfiguration) {
        self.configuration = configuration
        super.init()
    }
    
    func prepare(asset: AVURLAsset) {
        logger.info("Preparing FairPlay DRM")
        asset.resourceLoader.setDelegate(
            self,
            queue: DispatchQueue(label: "drm.resource.loader"))
    }
    
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        logger.info("FairPlay request received")
        guard let url = loadingRequest.request.url else {
            logger.error("Missing resource loading request URL")
            return false
        }
        
        guard url.scheme == "skd" else {
            return false
        }
        
        logger.info("DRM key request detected")
        
        Task {
            do {
                
                guard let contentIdentifier = contentIdentifier(from: url) else {
                    throw DRMError.invalidContentIdentifier
                }
                
                let certificate = try await fetchCertificate(
                    from: configuration.certificateURL
                )
                
                let spc = try makeSPC(
                    loadingRequest: loadingRequest,
                    certificate: certificate,
                    contentIdentifier: contentIdentifier
                )
                
                logger.info("SPC generated")
                
                let ckc = try await requestCKC(
                    spc: spc,
                    configuration: configuration
                )
                
                logger.info("CKC received")
                
                loadingRequest.dataRequest?.respond(with: ckc)
                loadingRequest.finishLoading()
                
            } catch {

                logger.error("FairPlay flow failed: \(error.localizedDescription)")
                loadingRequest.finishLoading(with: error)
                
            }
        }
        
        return true
    }
    
    private func fetchCertificate(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    private func contentIdentifier(from url: URL) -> Data? {
        if let override = configuration.contentIdentifierOverride {
            return override.data(using: .utf8)
        }
        
        let identifier = url.absoluteString
            .replacingOccurrences(of: "skd://", with: "")
        return identifier.data(using: .utf8)
    }
    
    private func makeSPC(
        loadingRequest: AVAssetResourceLoadingRequest,
        certificate: Data,
        contentIdentifier: Data
    ) throws -> Data {
        return try loadingRequest.streamingContentKeyRequestData(
            forApp: certificate,
            contentIdentifier: contentIdentifier,
            options: nil)
    }
    
    private func requestCKC(
        spc: Data,
        configuration: DRMConfiguration
    ) async throws -> Data {
        
        var components = URLComponents(url: configuration.licenseURL, resolvingAgainstBaseURL: false)
        
        if !configuration.queryItems.isEmpty {
            var items = components?.queryItems ?? []
            items.append(contentsOf: configuration.queryItems)
            components?.queryItems = items
        }
        
        guard let finalURL = components?.url else {
            throw DRMError.invalidLicenseURL
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "POST"
        request.httpBody = spc
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        for (key, value) in configuration.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("CKC response status: \(httpResponse.statusCode)")
        }
        
        return data
    }
}
