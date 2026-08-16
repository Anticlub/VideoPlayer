//
//  AuthViewModel.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 16/8/26.
//

import Foundation
import Observation

/// ViewModel de autenticación. Reúne la lógica de `SplashViewModel`, `LoginViewModel`
/// y `RegisterViewModel` de la app Android (mismas validaciones y estados).
///
/// Usa el framework Observation (`@Observable`), no Combine/`ObservableObject`.
@Observable
@MainActor
final class AuthViewModel {

    enum Session: Equatable {
        case checking
        case authenticated(AuthUser)
        case unauthenticated
    }

    enum FormState: Equatable {
        case idle
        case loading
        case error(AuthError)
    }

    private(set) var session: Session = .checking
    private(set) var formState: FormState = .idle

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = FirebaseAuthService()) {
        self.authService = authService
    }

    var isLoading: Bool { formState == .loading }

    /// Comprueba la sesión al arrancar (equivalente a `SplashViewModel`).
    func checkSession() async {
        // Pequeña espera para mostrar el splash, como el delay de 800 ms en Android.
        try? await Task.sleep(nanoseconds: 800_000_000)
        if let user = authService.currentUser {
            session = .authenticated(user)
        } else {
            session = .unauthenticated
        }
    }

    /// Login con email/contraseña (equivalente a `LoginViewModel.login`).
    func login(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            formState = .error(.emptyFields)
            return
        }
        formState = .loading
        do {
            let user = try await authService.login(email: email, password: password)
            session = .authenticated(user)
            formState = .idle
        } catch let error as AuthError {
            formState = .error(error)
        } catch {
            formState = .error(.unknown)
        }
    }

    /// Registro con confirmación de contraseña (equivalente a `RegisterViewModel.register`).
    func register(email: String, password: String, confirmPassword: String) async {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            formState = .error(.emptyFields)
            return
        }
        guard password == confirmPassword else {
            formState = .error(.passwordsDontMatch)
            return
        }
        formState = .loading
        do {
            let user = try await authService.register(email: email, password: password)
            session = .authenticated(user)
            formState = .idle
        } catch let error as AuthError {
            formState = .error(error)
        } catch {
            formState = .error(.unknown)
        }
    }

    func logout() {
        try? authService.logout()
        session = .unauthenticated
        formState = .idle
    }

    func resetFormState() {
        formState = .idle
    }
}
