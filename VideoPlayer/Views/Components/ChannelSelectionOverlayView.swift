//
//  ChannelSelectionOverlayView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 11/3/26.
//

import SwiftUI

struct ChannelSelectionOverlayView: View {
    let playlistSources: [PlaylistSource]
    let channels: [Channel]
    let focusedCardID: UUID?
    let focusBinding: FocusState<UUID?>.Binding
    let onSelectPlaylist: (PlaylistSource) -> Void
    let onSelectChannel: (Channel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PlaylistBarView(
                sources: playlistSources,
                onSelect: onSelectPlaylist
            )

            ChannelBarView(
                channels: channels,
                focusedCardID: focusedCardID,
                focusBinding: focusBinding,
                onSelect: onSelectChannel
            )
        }
        .padding(.top, 30)
        .transition(.opacity)
    }
}
