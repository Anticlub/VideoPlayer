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
                                .buttonStyle(.glass)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                    .frame(height: 120)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20){
                            ForEach(channelsByGroup,id: \.group) { group in
                            
                                Text(group.group)
                                    .font(.headline)
                                    .padding(.horizontal, 40)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 24) {
                                        ForEach(group.items) { channel in
                                            Button {
                                                vm.selectChannel(channel)
                                                hasSelectedChannel = true
                                                showChannelBar = false
                                            } label: {
                                                VStack(spacing: 10) {
                                                        if let logoURL = channel.logoURL {
                                                            AsyncImage(url: logoURL) { phase in
                                                                switch phase {
                                                                case .empty:
                                                                    RoundedRectangle(cornerRadius: 12)
                                                                        .fill(.black.opacity(0.4))
                                                                        .frame(width: 220, height: 124)

                                                                case .success(let image):
                                                                    image
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .frame(width: 220, height: 124)
                                                                        .clipShape(RoundedRectangle(cornerRadius: 12))

                                                                case .failure:
                                                                    RoundedRectangle(cornerRadius: 12)
                                                                        .fill(.black.opacity(0.4))
                                                                        .overlay(Text("Sin imagen").font(.caption))
                                                                        .frame(width: 220, height: 124)

                                                                @unknown default:
                                                                    RoundedRectangle(cornerRadius: 12)
                                                                        .fill(.black.opacity(0.4))
                                                                        .frame(width: 220, height: 124)
                                                                }
                                                            }

                                                            Text(channel.name)
                                                                .font(.caption)
                                                                .lineLimit(2)
                                                                .multilineTextAlignment(.center)
                                                                .frame(width: 220)
                                                        } else {
                                                            Text(channel.name)
                                                                .padding(.horizontal, 28)
                                                                .padding(.vertical, 14)
                                                        }
                                                    }
                                            }
                                            .buttonStyle(.glass)
                                            .focused($focusedChannelID, equals: channel.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 300)
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
