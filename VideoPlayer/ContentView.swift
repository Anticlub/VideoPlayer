//
//  ContentView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 2/3/26.
//

import SwiftUI

struct ContentView: View {
    private let streamURL = URL(
        string: "https://devstreaming-cdn.apple.com/videos/streaming/examplese/bipbop_adv_example_hevc/master.m3u8"
        )!
    @State private var playerState: PlayerState = .loading
    
    var body: some View {
        ZStack{
            PlayerView(url: streamURL, state: $playerState)
                 .ignoresSafeArea()
            overlayView
        }
       
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch playerState {
        case .playing:
            EmptyView()
        case .loading:
            Text("Cargando...")
                .padding()
                .background(.black.opacity(0.6))
        case .error(let message):
            VStack(spacing: 12) {
                Text("Error de reproducción")
                    .font(.headline)
                Text(message)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
