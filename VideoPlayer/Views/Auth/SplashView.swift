//
//  SplashView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 16/8/26.
//

#if os(iOS)
import SwiftUI

/// Pantalla de arranque mientras se comprueba la sesión.
/// Equivalente a `fragment_splash.xml` de Android (logo centrado + spinner).
struct SplashView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "play.tv.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(.tint)

            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SplashView()
}
#endif
