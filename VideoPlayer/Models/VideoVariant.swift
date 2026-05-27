//
//  VideoVariant.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 25/05/2026.
//

import AVFoundation

struct VideoVariant: Identifiable {
    let id = UUID()
    let variant: AVAssetVariant
    
    var bitRate: Double {
        variant.averageBitRate ?? 0
    }
    
    var displayName: String {
        if let height = variant.videoAttributes?.presentationSize.height {
            return "\(Int(height))p"
        }
        return "Auto"
    }
    
    var height: Int {
        if let height = variant.videoAttributes?.presentationSize.height {
            return Int(height)
        }
        return 0
    }
}
