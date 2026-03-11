//
//  PlaybackErrorOverlayView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 11/3/26.
//

import SwiftUI

struct PlaybackErrorOverlayView: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Text("Error de reproducción")
                .font(.headline)

            Text(message)
                .font(.footnote)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.black.opacity(0.7))
        .cornerRadius(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.35))
    }
}
