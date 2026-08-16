//
//  FirebaseAuthService.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 16/8/26.
//

import Foundation
import FirebaseAuth

/// Implementación de `AuthServiceProtocol` sobre Firebase Auth.
/// Comparte el mismo backend (proyecto Firebase) que la app Android.
final class FirebaseAuthService: AuthServiceProtocol {

    var currentUser: AuthUser? {
        Auth.auth().currentUser.map(Self.mapUser)
    }

    func login(email: String, password: String) async throws -> AuthUser {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return Self.mapUser(result.user)
        } catch {
            throw Self.mapError(error)
        }
    }

    func register(email: String, password: String) async throws -> AuthUser {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return Self.mapUser(result.user)
        } catch {
            throw Self.mapError(error)
        }
    }

    func logout() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw AuthError.unknown
        }
    }

    // MARK: - Mapping

    private static func mapUser(_ user: FirebaseAuth.User) -> AuthUser {
        AuthUser(uid: user.uid, email: user.email ?? "", displayName: user.displayName)
    }

    /// Traduce los códigos de error de Firebase a `AuthError`, en paralelo al mapeo
    /// de excepciones que hace `AuthRepositoryImpl` en la app Android.
    private static func mapError(_ error: Error) -> AuthError {
        guard let code = AuthErrorCode(rawValue: (error as NSError).code) else {
            return .unknown
        }
        switch code {
        case .wrongPassword, .invalidCredential, .userMismatch:
            return .invalidCredentials
        case .userNotFound, .userDisabled:
            return .userNotFound
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .invalidEmail:
            return .invalidEmail
        case .networkError:
            return .network
        default:
            return .unknown
        }
    }
}
