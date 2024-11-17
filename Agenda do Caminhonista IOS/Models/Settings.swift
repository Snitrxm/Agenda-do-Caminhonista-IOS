//
//  Settings.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 07/11/2024.
//

struct SettingsStruct: Encodable, Decodable {
    let id: String
    let userId: String
    let defaultTruckPlate: String?
    let defaultTrailerPlate: String?
    let createdAt: String
    let updatedAt: String
}
