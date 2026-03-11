//
//  PlaylistBar.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 11/3/26.
//

import SwiftUI

struct PlaylistBarView: View {
    let sources: [PlaylistSource]
    let onSelect: (PlaylistSource) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(sources) { source in
                    Button {
                        onSelect(source)
                    } label: {
                        Text("\(source.kind.rawValue): \(source.name)")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal, 40)
        }
        .frame(height: 100)
    }
}
