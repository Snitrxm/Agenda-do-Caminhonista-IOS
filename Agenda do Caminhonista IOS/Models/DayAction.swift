//
//  DayAction.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 31/10/2024.
//

struct DayActionStruct: Encodable, Decodable {
    let id: String
    let dayId: String
    let action: String
    var date: String
    var local: String
    let latitude: String?
    let longitude: String?
    var additionalInformations: String?
    let createdAt: String
    let updatedAt: String
}
