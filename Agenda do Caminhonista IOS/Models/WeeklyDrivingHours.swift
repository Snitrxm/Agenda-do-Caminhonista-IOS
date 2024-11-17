//
//  WeeklyDrivingHours.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 15/11/2024.
//

struct WeeklyDrivingHoursStruct: Encodable, Decodable {
    let weekStart: String
    let weekEnd: String
    let drivingMinutes: Int
}
