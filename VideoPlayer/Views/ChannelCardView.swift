//
//  ChannelCardView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 11/3/26.
//

import SwiftUI

struct ChannelCardView: View {
    let channel: Channel
    let isFocused: Bool
    let onSelect: () -> Void

    var body: some View {
        Button {
            onSelect()
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.black.opacity(0.35))

                    if let logoURL = channel.logoURL {
                        AsyncImage(url: logoURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()

                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .padding(18)

                            case .failure:
                                fallbackImage

                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        fallbackImage
                    }

                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            isFocused ? .white.opacity(0.9) : .clear,
                            lineWidth: 3
                        )
                }
                .frame(width: 260, height: 150)
                .shadow(radius: isFocused ? 16 : 6)

                Text(channel.name)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 260)
            }
            .scaleEffect(isFocused ? 1.12 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isFocused)
        }
        .buttonStyle(.glass)
    }

    private var fallbackImage: some View {
        Image(systemName: "tv")
            .font(.system(size: 34))
            .foregroundStyle(.white.opacity(0.7))
    }
}
