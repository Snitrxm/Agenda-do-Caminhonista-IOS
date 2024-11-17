//
//  User.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 28/10/2024.
//

struct UserStruct: Encodable, Decodable {
    let id: String
    let name: String
    let email: String
    let password: String
}
