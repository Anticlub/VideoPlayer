//
//  ContentView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 2/3/26.
//

import SwiftUI

struct ContentView: View {
    private let streamURL = URL(
        string: "https://rtvelivestream.rtve.es/rtvesec/la1/la1_main_dvr.m3u8"
        )!
    var body: some View {
       PlayerView(url: streamURL)
            .ignoresSafeArea()
    }
}
