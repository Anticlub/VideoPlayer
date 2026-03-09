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
    }
    
    private let configuration: DRMConfiguration
    
    init(configuration: DRMConfiguration) {
        self.configuration = configuration
        super.init()
    }
    
    func prepare(asset: AVURLAsset) {
        asset.resourceLoader.setDelegate(
            self,
            queue: DispatchQueue(label: "drm.resource.loader"))
    }
    
    func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        guard let url = loadingRequest.request.url else {
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
                    licenseURL: configuration.licenseURL
                )

                print("✅ CKC recibido")

                loadingRequest.dataRequest?.respond(with: ckc)
                loadingRequest.finishLoading()

            } catch {

                print("❌ DRM error:", error.localizedDescription)
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
        guard let host = url.host else { return nil }
        return host.data(using: .utf8)
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
        licenseURL: URL
    ) async throws -> Data {
        
        var request = URLRequest(url: licenseURL)
        request.httpMethod = "POST"
        request.httpBody = spc
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return data
    }
    
}
