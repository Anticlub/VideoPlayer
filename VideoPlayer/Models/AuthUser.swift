//
//  AuthUser.swift
//  VideoPlayer
//
//  Created by cristofer fernandez on 16/8/26.
//

import Foundation

/// Usuario autenticado. Equivalente al modelo `User` de la app Android.
struct AuthUser: Equatable {
    let uid: String
    let email: String
    let displayName: String?

    init(uid: String, email: String, displayName: String? = nil) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }
}
