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
                            .buttonStyle(.borderedProminent)
                            .focused($focusedChannelID, equals: channel.id)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 30)
                }
//                .frame(height: 130)
//                .padding(.vertical, 30)
                .transition(.opacity)
            }
            
            overlayView
        }
        .onChange(of: showChannelBar) { _, isShown in
            if isShown {
                focusedChannelID = vm.selectedChannel.id
            } else {
                focusedChannelID = nil
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
