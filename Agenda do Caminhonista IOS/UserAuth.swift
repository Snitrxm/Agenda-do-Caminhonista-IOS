//
//  UserAuth.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 28/10/2024.
//

import SwiftUI
import Combine

class UserAuth: ObservableObject {
    static var token: String? = nil
    static var user: UserStruct? = nil
    
    static func setToken(token: String) {
        self.token = token
    }
    
    static func setUser(user: UserStruct) {
        self.user = user
    }
}

