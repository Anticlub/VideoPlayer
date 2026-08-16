//
//  AuthError.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 16/8/26.
//

import Foundation

/// Errores de autenticación tipados. Equivalente a `AuthErrorType` de la app Android,
/// con los mismos mensajes en español (strings `auth_error_*`).
enum AuthError: Error, Equatable {
    case passwordsDontMatch
    case emptyFields
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case invalidEmail
    case network
    case unknown

    var message: String {
        switch self {
        case .passwordsDontMatch: return "Las contraseñas no coinciden"
        case .emptyFields:        return "Rellena todos los campos"
        case .invalidCredentials: return "Email o contraseña incorrectos"
        case .userNotFound:       return "Email o contraseña incorrectos"
        case .emailAlreadyInUse:  return "Ese email ya está registrado"
        case .weakPassword:       return "La contraseña debe tener al menos 6 caracteres"
        case .invalidEmail:       return "El formato del email no es válido"
        case .network:            return "Sin conexión a internet"
        case .unknown:            return "Ha ocurrido un error, inténtalo de nuevo"
        }
    }
}
