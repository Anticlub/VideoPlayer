//
//  ChannelBarView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 11/3/26.
//

import SwiftUI

struct ChannelBarView: View {
    let channels: [Channel]
    let focusedCardID: UUID?
    let focusBinding: FocusState<UUID?>.Binding
    let onSelect: (Channel) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 70) {
                ForEach(channels) { channel in
                    ChannelCardView(
                        channel: channel,
                        isFocused: focusedCardID == channel.id,
                        onSelect: {
                            onSelect(channel)
                        }
                    )
                    .focused(focusBinding, equals: channel.id)
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 22)
        }
        .frame(height: 260)
    }
}
