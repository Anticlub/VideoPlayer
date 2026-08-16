//
//  RegisterView.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 16/8/26.
//

#if os(iOS)
import SwiftUI

/// Pantalla de registro. Clona `fragment_register.xml` de Android:
/// título, email, contraseña, confirmar contraseña, botón, enlace a login, error y spinner.
struct RegisterView: View {
    @Environment(AuthViewModel.self) private var auth
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Text("Crear cuenta")
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
                    .textContentType(.newPassword)
                    .textFieldStyle(.roundedBorder)

                SecureField("Confirmar contraseña", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .textFieldStyle(.roundedBorder)

                Button {
                    Task {
                        await auth.register(
                            email: email.trimmingCharacters(in: .whitespaces),
                            password: password,
                            confirmPassword: confirmPassword
                        )
                    }
                } label: {
                    Text("Registrarse")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(auth.isLoading)
                .padding(.top, 8)

                Button("¿Ya tienes cuenta? Inicia sesión") {
                    dismiss()
                }
                .padding(12)

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
        RegisterView().environment(AuthViewModel(authService: PreviewAuthService()))
    }
}
#endif
