//
//  DRMManager.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 9/3/26.
//

import AVFoundation

final class DRMManager: NSObject, AVAssetResourceLoaderDelegate {
    
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
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
            print("DRMManager recibió una petición de recurso protegido")
                    print("License URL configurada: \(configuration.licenseURL.absoluteString)")
                    print("Requested URL: \(loadingRequest.request.url?.absoluteString ?? "nil")")
            
            return true
    }
    
}
