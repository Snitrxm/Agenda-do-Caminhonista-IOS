//
//  Day.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 31/10/2024.
//

struct DayStruct: Encodable, Decodable {
    let id: String
    let userId: String
    let date: String
    var weekStart: Bool
    var departureKm: Int?
    var arriveKm: Int?
    var drivingMinutes: Int?
    var truckPlate: String?
    var trailerPlate: String?
    let createdAt: String
    let updatedAt: String
    var observations: String?
    var actions: [DayActionStruct]?
}
