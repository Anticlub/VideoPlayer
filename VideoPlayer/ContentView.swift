//
//  ContentView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 2/3/26.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var vm = PlayerViewModel()
    
    var body: some View {
        ZStack{
            VStack(spacing: 30) {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(vm.channels) { channel in
                            Button {
                                vm.selectChannel(channel)
                            } label: {
                                Text(channel.name)
                                    .padding(.horizontal, 28)
                                    .padding(.vertical)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .frame(height: 90)
                
                PlayerView(url: vm.url, state: $vm.state)
                    .id(vm.playerInstanceID)
                    .ignoresSafeArea()
            }
            overlayView
        }
       
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch vm.state {
        case .playing:
            EmptyView()
            
        case .loading:
            VStack{
                Text("Cargando...")
                    .padding()
                    .background(.black.opacity(0.6))
                    .cornerRadius(16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.35))
            
        case .error(let message):
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
        }
    }
}
