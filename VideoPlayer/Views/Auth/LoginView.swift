//
//  LoginView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 16/8/26.
//

#if os(iOS)
import SwiftUI

/// Pantalla de inicio de sesión. Clona el layout de `fragment_login.xml` de Android:
/// título, email, contraseña, botón, enlace a registro, error y spinner.
struct LoginView: View {
    @Environment(AuthViewModel.self) private var auth
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Text("Iniciar sesión")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 48)

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .padding(.top, 32)

                SecureField("Contraseña", text: $password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)

                Button {
                    Task {
                        await auth.login(
                            email: email.trimmingCharacters(in: .whitespaces),
                            password: password
                        )
                    }
                } label: {
                    Text("Entrar")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(auth.isLoading)
                .padding(.top, 8)

                NavigationLink {
                    RegisterView()
                } label: {
                    Text("¿No tienes cuenta? Regístrate")
                        .padding(12)
                }

                if case .error(let error) = auth.formState {
                    Text(error.message)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                Spacer()
            }
            .padding(24)

            if auth.isLoading {
                ProgressView()
            }
        }
        .onAppear { auth.resetFormState() }
    }
}

#Preview {
    NavigationStack {
        LoginView().environment(AuthViewModel(authService: PreviewAuthService()))
    }
}
#endif
