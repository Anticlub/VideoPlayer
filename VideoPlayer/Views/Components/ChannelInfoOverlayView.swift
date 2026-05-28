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
    let quality: String?
    var body: some View {
        ZStack (alignment: .topLeading ){
            Color.clear
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
                if let quality = quality {
                    Text(quality)
                }
            }
            .padding()
            .background(.black.opacity(0.35))
            .cornerRadius(12)
        }
        .padding(.top, 60)
        .padding(.horizontal, 60)
    }
}

#Preview {
    ChannelInfoOverlayView(
        name: "Canal 24h",
        logoURL: URL(string: "https://graph.facebook.com/radionacionalrne/picture?width=200&height=200"),
        groupTitle: "Noticias",
        quality: "1080p"
    )
}
