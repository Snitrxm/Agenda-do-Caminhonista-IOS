//
//  WeeklyDrivingHoursViewModel.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 15/11/2024.
//

import Foundation

class WeeklyDrivingHoursViewModel: ObservableObject {
    @Published var weeklyDrivingHours: [WeeklyDrivingHoursStruct] = []
    @Published var filterText: String = ""
    
    var filteredWeeklyDrivingHours: [WeeklyDrivingHoursStruct] {
        guard !filterText.isEmpty else { return weeklyDrivingHours }
        return weeklyDrivingHours.filter { $0.weekStart.localizedCaseInsensitiveContains(filterText) }
    }
    
    func handleGetWeeklyDrivingHours() {
        DayServices.getWeeklyDrivingHours { (result: Result<[WeeklyDrivingHoursStruct], NetworkError>) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.weeklyDrivingHours = response
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
