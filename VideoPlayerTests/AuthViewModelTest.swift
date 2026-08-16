//
//  AuthViewModelTest.swift
//  VideoPlayerTests
//
//  Created by cristofer fernandez on 16/8/26.
//

import Testing
@testable import VideoPlayer

// MARK: - Mock

final class MockAuthService: AuthServiceProtocol {
    var currentUser: AuthUser?
    var loginResult: Result<AuthUser, Error>
    var registerResult: Result<AuthUser, Error>
    private(set) var logoutCalled = false

    init(
        currentUser: AuthUser? = nil,
        loginResult: Result<AuthUser, Error> = .success(AuthUser(uid: "1", email: "user@test.com")),
        registerResult: Result<AuthUser, Error> = .success(AuthUser(uid: "1", email: "user@test.com"))
    ) {
        self.currentUser = currentUser
        self.loginResult = loginResult
        self.registerResult = registerResult
    }

    func login(email: String, password: String) async throws -> AuthUser { try loginResult.get() }
    func register(email: String, password: String) async throws -> AuthUser { try registerResult.get() }
    func logout() throws { logoutCalled = true }
}

// MARK: - Login

@Test @MainActor func login_withEmptyFields_setsEmptyFieldsError() async {
    let vm = AuthViewModel(authService: MockAuthService())
    await vm.login(email: "", password: "")
    #expect(vm.formState == .error(.emptyFields))
}

@Test @MainActor func login_success_authenticatesSession() async {
    let user = AuthUser(uid: "42", email: "user@test.com")
    let vm = AuthViewModel(authService: MockAuthService(loginResult: .success(user)))
    await vm.login(email: "user@test.com", password: "123456")
    #expect(vm.session == .authenticated(user))
    #expect(vm.formState == .idle)
}

@Test @MainActor func login_failure_mapsError() async {
    let vm = AuthViewModel(authService: MockAuthService(loginResult: .failure(AuthError.invalidCredentials)))
    await vm.login(email: "user@test.com", password: "wrong")
    #expect(vm.formState == .error(.invalidCredentials))
}

// MARK: - Register

@Test @MainActor func register_withEmptyFields_setsEmptyFieldsError() async {
    let vm = AuthViewModel(authService: MockAuthService())
    await vm.register(email: "", password: "", confirmPassword: "")
    #expect(vm.formState == .error(.emptyFields))
}

@Test @MainActor func register_withMismatchedPasswords_setsError() async {
    let vm = AuthViewModel(authService: MockAuthService())
    await vm.register(email: "user@test.com", password: "123456", confirmPassword: "999999")
    #expect(vm.formState == .error(.passwordsDontMatch))
}

@Test @MainActor func register_success_authenticatesSession() async {
    let user = AuthUser(uid: "7", email: "new@test.com")
    let vm = AuthViewModel(authService: MockAuthService(registerResult: .success(user)))
    await vm.register(email: "new@test.com", password: "123456", confirmPassword: "123456")
    #expect(vm.session == .authenticated(user))
}

// MARK: - Session

@Test @MainActor func checkSession_withExistingUser_authenticates() async {
    let user = AuthUser(uid: "1", email: "user@test.com")
    let vm = AuthViewModel(authService: MockAuthService(currentUser: user))
    await vm.checkSession()
    #expect(vm.session == .authenticated(user))
}

@Test @MainActor func checkSession_withoutUser_unauthenticated() async {
    let vm = AuthViewModel(authService: MockAuthService(currentUser: nil))
    await vm.checkSession()
    #expect(vm.session == .unauthenticated)
}
