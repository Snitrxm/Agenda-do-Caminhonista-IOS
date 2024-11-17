//
//  WeeklyDrivingHoursView.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 15/11/2024.
//

import SwiftUI

struct WeeklyDrivingHoursSheet: View {
    @StateObject private var viewModel = WeeklyDrivingHoursViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                List(viewModel.filteredWeeklyDrivingHours, id: \.weekStart) { item in
                    GroupBox(label: Text("\(item.weekStart) - \(item.weekEnd)"), content: {
                        VStack {
                            Text("\(DateUtils.minutesToHours(item.drivingMinutes))")
                        }
                    })
                    .groupBoxStyle(GroupBoxCardStyle())
                }
                .searchable(text: $viewModel.filterText, prompt: "Pesquise pela semana")
                .listStyle(PlainListStyle())
                .listRowSeparator(.hidden)
            }
            .task {
                viewModel.handleGetWeeklyDrivingHours()
            }
            .navigationTitle("Condução Semanal")
        }
    }
}

#Preview {
    UserAuth.setToken(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Ijc2NjVlMzM2LTdkYjMtNGE3MS05MmRkLWE5MzhkZjQ5Y2Q2OCIsImVtYWlsIjoiYW5kcmVAZ21haWwuY29tIiwiaWF0IjoxNzMxNjEwNzQ2LCJleHAiOjE3MzE2OTcxNDZ9.9L6xMjPQ3HIODrJYsc9yJv35dO5MNL1YQKdDOrDtEg8")
    
    return WeeklyDrivingHoursSheet()
}
