//
//  PreviewAuthService.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 16/8/26.
//

#if os(iOS) && DEBUG
import Foundation

/// Servicio de autenticación de mentira, únicamente para las `#Preview` de SwiftUI
/// (evita depender de Firebase al renderizar los previews).
final class PreviewAuthService: AuthServiceProtocol {
    var currentUser: AuthUser?

    init(currentUser: AuthUser? = nil) {
        self.currentUser = currentUser
    }

    func login(email: String, password: String) async throws -> AuthUser {
        AuthUser(uid: "preview", email: email)
    }

    func register(email: String, password: String) async throws -> AuthUser {
        AuthUser(uid: "preview", email: email)
    }

    func logout() throws {}
}
#endif
