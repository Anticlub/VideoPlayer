//
//  RootView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 16/8/26.
//

import SwiftUI

/// Puerta de arranque de la app.
///
/// - En **iPhone** exige login (splash → login/registro → player), igual que Android.
/// - En **tvOS** el login es incómodo con el mando, así que se salta y va directo al player.
struct RootView: View {

    #if os(iOS)
    @State private var auth = AuthViewModel()
    #endif

    var body: some View {
        #if os(tvOS)
        ContentView()
        #else
        content
        #endif
    }

    #if os(iOS)
    @ViewBuilder
    private var content: some View {
        Group {
            switch auth.session {
            case .checking:
                SplashView()
            case .authenticated:
                ContentView()
            case .unauthenticated:
                NavigationStack {
                    LoginView()
                }
            }
        }
        .environment(auth)
        .task { await auth.checkSession() }
    }
    #endif
}
