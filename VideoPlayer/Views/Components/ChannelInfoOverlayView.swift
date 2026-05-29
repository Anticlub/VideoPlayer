//
//  ChannelInfoOverlayView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 28/05/2026.
//

import SwiftUI

struct ChannelInfoOverlayView: View {
    let name: String
    let logoURL: URL?
    let groupTitle: String?
    let quality: String
    var body: some View {
        HStack {
            if let logo = logoURL {
                AsyncImage(url: logo) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                    case .failure(_):
                        EmptyView()
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            Text(name)
            if let group = groupTitle {
                Text(group)
            }
            Text(quality)
        }
        .padding()
        .background(.black.opacity(0.35))
        .cornerRadius(12)
    }
}
