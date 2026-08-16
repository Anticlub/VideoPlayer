//
//  AuthServiceProtocol.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 16/8/26.
//

import Foundation

/// Abstracción del backend de autenticación. Equivalente a `AuthRepository` de Android.
/// Permite inyectar un mock en tests, igual que `PlayerServiceProtocol`.
protocol AuthServiceProtocol {
    var currentUser: AuthUser? { get }
    func login(email: String, password: String) async throws -> AuthUser
    func register(email: String, password: String) async throws -> AuthUser
    func logout() throws
}
