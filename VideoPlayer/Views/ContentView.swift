//
//  ContentView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 2/3/26.
//

import SwiftUI

struct ContentView: View {
    @State private var playlistURL = URL(string: "https://www.tdtchannels.com/lists/tv_mpd.m3u8")!
    @StateObject private var vm = PlayerViewModel()
    @State private var showChannelBar = true
    @State private var hasSelectedChannel = false
    @FocusState private var focusedChannelID: UUID?
    
    var body: some View {
        ZStack(alignment: .top) {
            
            if hasSelectedChannel {
                PlayerView(url: vm.url, state: $vm.state)
                    .id(vm.playerInstanceID)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            if showChannelBar {
                VStack(alignment: .leading, spacing: 18) {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 18) {
                            ForEach(vm.playlistSources) {source in
                                Button {
                                    Task {
                                        await vm.selectPlaylist(source)
                                    }
                                } label: {
                                    Text("\(source.kind.rawValue): \(source.name)")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                    .frame(height: 70)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(vm.channels) { channel in
                                Button {
                                    vm.selectChannel(channel)
                                    hasSelectedChannel = true
                                    showChannelBar = false
                                } label: {
                                    Text(channel.name)
                                        .padding(.horizontal, 28)
                                        .padding(.vertical, 14)
                                }
                                .buttonStyle(.glass)
                                .focused($focusedChannelID, equals: channel.id)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 22)
                    }
                    .frame(height: 140)
                }
                .padding(.top, 30)
                .transition(.opacity)
                
            }
            
            overlayView
        }
        .task {
            await vm.loadPlaylist(from: playlistURL)
        }
        .onChange(of: showChannelBar) { _, isShown in
            if isShown {
                focusedChannelID = vm.selectedChannel.id
            } else {
                focusedChannelID = nil
            }
        
        }
        .onChange(of: vm.state) {_, newValue in
            if case .error = newValue {
                showChannelBar = true
                DispatchQueue.main.async {
                    focusedChannelID = vm.selectedChannel.id
                }
            }
        }
        .onExitCommand {
            showChannelBar = true
            focusedChannelID = vm.selectedChannel.id
        }
        
    }
    
    @ViewBuilder
    private var overlayView: some View {
        if case .error(let message) = vm.state {
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
        } else {
            EmptyView()
        }
    }
}
