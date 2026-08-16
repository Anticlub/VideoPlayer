//
//  VideoPlayerApp.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 2/3/26.
//

import SwiftUI
import FirebaseCore

/// Inicializa Firebase al arrancar. La comprobación del plist evita un crash si el
/// `GoogleService-Info.plist` no está presente (p. ej. en un entorno de CI sin él).
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
        return true
    }
}

@main
struct VideoPlayerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
