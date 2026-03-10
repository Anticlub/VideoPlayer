//
//  DRMManager.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 9/3/26.
//

import AVFoundation

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
        print("DRMManager: preparing FairPlay DRM")
        asset.resourceLoader.setDelegate(
            self,
            queue: DispatchQueue(label: "drm.resource.loader"))
    }
    
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        guard let url = loadingRequest.request.url else {
            print("DRMManager: missing request URL")
            return false
        }
        
        print("Resource request URL: \(url.absoluteString)")
        
        guard url.scheme == "skd" else {
            print("La petición no es DRM (no es skd://)")
            return false
        }
        
        print("🔐 DRM request detectada (skd://)")
        
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
                
                print("✅ SPC generado")
                
                let ckc = try await requestCKC(
                    spc: spc,
                    configuration: configuration
                )
                
                print("✅ CKC recibido")
                
                loadingRequest.dataRequest?.respond(with: ckc)
                loadingRequest.finishLoading()
                
                print("DRMManager: loadingRequest finished successfully")
            } catch {
                
                print("❌ DRM error:", error.localizedDescription)
                loadingRequest.finishLoading(with: error)
                
            }
        }
        
        return true
    }
    
    private func fetchCertificate(from url: URL) async throws -> Data {
        print("Fetching certificate from: \(url.absoluteString)")
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
        print("Requesting CKC from: \(configuration.licenseURL.absoluteString)")
        
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
