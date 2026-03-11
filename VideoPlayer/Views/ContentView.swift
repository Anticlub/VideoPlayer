//
//  ContentView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 2/3/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = PlayerViewModel()
    @State private var showChannelBar = true
    @State private var hasSelectedChannel = false
    @FocusState private var focusedCardID: UUID?
    @State private var showControls = false
    
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

            if hasSelectedChannel && !showChannelBar && showControls {
                controlsLayer
            }

            overlayView
        }
        .task {
            await vm.loadInitialPlaylist()
        }
        .onChange(of: showChannelBar) { _, isShown in
            if isShown {
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
        .onExitCommand {
            if showChannelBar {
                withAnimation(.easeInOut) { showChannelBar = false }
                showControls = false
                focusedCardID = nil
            } else {
                showControls.toggle()
                showChannelBar = false
            }
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        if case .error(let message) = vm.state {
            PlaybackErrorOverlayView(message: message)
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
                    showsPlaybackControls: !showControls || showChannelBar
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
            }
        )
    }
    
    private var controlsLayer: some View {
        VStack {
            Spacer()

            PlayerControlsView(
                onPrevious: vm.previousChannel,
                onPlayPause: vm.playPause,
                onNext: vm.nextChannel,
                onStop: {
                    vm.stop()
                    showControls = false
                    showChannelBar = true
                }
            )
            .padding(.bottom, 140)
        }
        .zIndex(50)
        .transition(.opacity)
    }
}
