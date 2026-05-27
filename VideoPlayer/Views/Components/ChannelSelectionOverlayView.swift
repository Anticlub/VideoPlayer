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
    let variantsAvailables: [VideoVariant]
    let selectedVariant: VideoVariant?
    let onSelectVariant: (VideoVariant) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            
            if variantsAvailables.count > 1 {
                QualityPickerView(
                    variants: variantsAvailables,
                    selectedVariant: selectedVariant,
                    onSelect: onSelectVariant)
            }
            
            PlaylistBarView(
                sources: playlistSources,
                onSelect: onSelectPlaylist
            )
            #if os(tvOS)
            .focusSection()
            #endif
            ChannelBarView(
                channels: channels,
                focusedCardID: focusedCardID,
                focusBinding: focusBinding,
                onSelect: onSelectChannel
            )
            #if os(tvOS)
            .focusSection()
            #endif
        }
        .padding(.top, 30)
        .transition(.opacity)
    }
}
