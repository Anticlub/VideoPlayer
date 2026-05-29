//
//  ContentView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 2/3/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = PlayerViewModel(playerService: PlayerService())
    @State private var showChannelBar = true
    @State private var showChannelInfo = false
    @State private var hasSelectedChannel = false
    @State private var channelInfoTask: Task<Void, Never>?
    @FocusState private var focusedCardID: UUID?
    
    private var channelsByGroup: [(group: String, items: [Channel])] {
        
        let grouped = Dictionary(grouping: vm.channels) { channel in
            channel.groupTitle ?? "Otros"
        }

        return grouped
            .map { ($0.key, $0.value) }
            .sorted { $0.0 < $1.0 }
    }
    
    var body: some View {
        ZStack(alignment: .top) {

            playerLayer

            if showChannelBar {
                channelSelectionLayer
            }
            
            if showChannelInfo {
                ChannelInfoOverlayView(
                    name: vm.playingChannel?.name ?? "",
                    logoURL: vm.playingChannel?.logoURL,
                    groupTitle: vm.playingChannel?.groupTitle,
                    quality: vm.selectedVariant?.displayName ?? "Auto"
                )
                .transition(.opacity)
            }

            overlayView
        }
        .animation(.easeInOut, value: showChannelInfo)
        .task {
            await vm.loadInitialPlaylist()
        }
        .onChange(of: showChannelBar) { _, isShown in
            if isShown {
                showChannelInfo = false
                focusedCardID = vm.selectedChannel.id
            } else {
                focusedCardID = nil
            }
        }
        .onChange(of: vm.state) { _, newValue in
            if case .error = newValue {
                showChannelBar = true
                DispatchQueue.main.async {
                    focusedCardID = vm.selectedChannel.id
                }
            }
        }
        #if os(tvOS)
        .onExitCommand {
            if showChannelBar {
                showChannelBar = false
                focusedCardID = nil
            } else {
                showChannelBar = true
            }
        }
        #endif
        #if os(iOS)
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.width > 100 {
                    showChannelBar = true
                }
            }
        )
        #endif
    }
    
    @ViewBuilder
    private var overlayView: some View {
        if case .error(let message) = vm.state {
            PlaybackErrorOverlayView(message: message, onTap: {
                showChannelBar = true
                vm.setIdle()
                }
            )
        } else {
            EmptyView()
        }
    }
    
    private var playerLayer: some View {
        Group {
            if hasSelectedChannel {
                PlayerView(
                    player: vm.player,
                    state: $vm.state,
                    showsPlaybackControls: !showChannelBar
                )
                .id(vm.playerInstanceID)
                .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
        }
    }
    
    private var channelSelectionLayer: some View {
        ChannelSelectionOverlayView(
            playlistSources: vm.playlistSources,
            channels: vm.channels,
            focusedCardID: focusedCardID,
            focusBinding: $focusedCardID,
            onSelectPlaylist: { source in
                Task {
                    await vm.selectPlaylist(source)
                }
            },
            onSelectChannel: { channel in
                vm.selectChannel(channel)
                hasSelectedChannel = true
                showChannelBar = false
                showChannelInfo = true
                channelInfoTask?.cancel()
                channelInfoTask = Task {
                    try? await Task.sleep(for: .seconds(5))
                    showChannelInfo = false
                }
            },
            variantsAvailables: vm.uniqueVariantsByHeight,
            selectedVariant: vm.selectedVariant,
            onSelectVariant: { variant in
                vm.selectVariant(variant)
                
            }
        )
    }
    
}
