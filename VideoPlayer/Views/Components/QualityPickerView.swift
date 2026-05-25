//
//  QualityPickerView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 25/05/2026.
//

import SwiftUI
import AVFoundation

struct QualityPickerView: View {
    let variants: [VideoVariant]
    let selectedVariant: VideoVariant?
    let onSelect: (VideoVariant) -> Void
    
    var body: some View {
        Menu {
            ForEach(variants) { variant in
                Button {
                    onSelect(variant)
                } label: {
                    if selectedVariant?.id == variant.id {
                        Label(variant.displayName, systemImage: "checkmark")
                    } else {
                        Text(variant.displayName)
                    }
                }
            }
        } label: {
            Image(systemName: "video.badge.checkmark")
        }
    }
}
