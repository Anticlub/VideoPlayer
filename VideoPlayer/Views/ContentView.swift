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
                    .frame(height: 100)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20){
                            ForEach(channelsByGroup,id: \.group) { group in
                            
                                Text(group.group)
                                    .font(.headline)
                                    .padding(.horizontal, 40)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 70) {
                                        ForEach(group.items) { channel in
                                            Button {
                                                vm.selectChannel(channel)
                                                hasSelectedChannel = true
                                                showChannelBar = false
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
                                                                    Image(systemName: "tv")
                                                                        .font(.system(size: 34))
                                                                        .foregroundStyle(.white.opacity(0.7))
                                                                @unknown default:
                                                                    EmptyView()
                                                                }
                                                            }
                                                        } else {
                                                            Image(systemName: "tv")
                                                                .font(.system(size: 34))
                                                                .foregroundStyle(.white.opacity(0.7))
                                                        }

                                                        // Borde cuando está enfocado
                                                        RoundedRectangle(cornerRadius: 18)
                                                            .stroke(
                                                                focusedCardID == channel.id ? .white.opacity(0.9) : .clear,
                                                                lineWidth: 3
                                                            )
                                                    }
                                                    .frame(width: 260, height: 150)
                                                    .shadow(radius: focusedCardID == channel.id ? 16 : 6)

                                                    Text(channel.name)
                                                        .font(.caption)
                                                        .lineLimit(2)
                                                        .multilineTextAlignment(.center)
                                                        .frame(width: 260)
                                                }
                                                // Zoom con foco
                                                .scaleEffect(focusedCardID == channel.id ? 1.12 : 1.0)
                                                .animation(.easeInOut(duration: 0.15), value: focusedCardID)
                                            }
                                            .buttonStyle(.glass)
                                            .focused($focusedCardID, equals: channel.id)
                                        }
                                    }
                                    .padding(.vertical, 22)
                                }
                            }
                        }
                    }
                    .frame(height: 330)
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
                focusedCardID = vm.selectedChannel.id
            } else {
                focusedCardID = nil
            }
        
        }
        .onChange(of: vm.state) {_, newValue in
            if case .error = newValue {
                showChannelBar = true
                DispatchQueue.main.async {
                    focusedCardID = vm.selectedChannel.id
                }
            }
        }
        .onExitCommand {
            showChannelBar = true
            focusedCardID = vm.selectedChannel.id
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
