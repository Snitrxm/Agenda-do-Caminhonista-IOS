//
//  CreateActionSheet.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 01/11/2024.
//

import NotificationCenter

struct CreateActionResponse: Encodable, Decodable {
    let id: String
    let action: String
    let date: String
    let local: String
    let createdAt: String
    let updatedAt: String
    let additionalInformations: String
    let latitude: String
    let longitude: String
}

import SwiftUI

struct CreateActionSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: CreateActionViewModel
    
    @Binding var day: DayStruct
    @Binding var actions: [DayActionStruct]

    
    init(day: Binding<DayStruct>, actions: Binding<[DayActionStruct]>) {
        _day = day
        _actions = actions
        let locationManager = LocationManager()
        _viewModel = StateObject(wrappedValue: CreateActionViewModel(day: day, actions: actions, locationManager: locationManager))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Ação", selection: $viewModel.selectedAction) {
                    ForEach(viewModel.actionsList, id: \.self) { name in
                            Text(name)
                    }
                }
                
                TextField("Local", text: $viewModel.local)
                TextEditor(text: $viewModel.additionalInformations)
                
                BigButton(text: "Criar", isLoading: viewModel.isLoading, action: {
                    viewModel.handleCreateAction()
                })
            }
            .navigationTitle("Criar ação")
        }
        .alert(isPresented: $viewModel.isShowingErrorAlert) {
            Alert(title: Text("Um erro aconteceu"), message: Text("\(viewModel.errorMessage)"))
        }
        .onChange(of: viewModel.didCreateAction) {
            if viewModel.didCreateAction {
                dismiss()
            }
        }
        .onChange(of: viewModel.locationManager.city) {
            viewModel.updateLocal()
        }
        .onReceive(viewModel.locationManager.$city) { _ in
            viewModel.updateLocal()
        }
        .onReceive(viewModel.locationManager.$country) { _ in
            viewModel.updateLocal()
        }
        .onAppear {
            viewModel.locationManager.startUpdatingLocation()
        }
        .onDisappear {
            viewModel.locationManager.stopUpdatingLocation()
        }
    }
}

#Preview {
    let initialActions = [
        DayActionStruct(id: "1", dayId: "1", action: "Partida", date: "2024-10-31T11:12:08.080Z",
                        local: "Viana do Castelo - Portugal", latitude: "37.3347302", longitude: "-122.0089189", additionalInformations: "n Tem", createdAt: "2024-10-31T11:12:08.080Z", updatedAt: "2024-10-31T11:12:08.080Z")
    ]
    
    let initialDay = DayStruct(
        id: "1",
        userId: "2",
        date: "2024-10-31T11:12:08.080Z",
        weekStart: true,
        departureKm: 100,
        arriveKm: 200,
        drivingMinutes: 60,
        truckPlate: "aaaa",
        trailerPlate: "bbbb",
        createdAt: "2024-10-31T11:12:08.080Z",
        updatedAt: "2024-10-31T11:12:08.080Z",
        observations: "",
        actions: initialActions
    )
    
    @State var actions = initialActions
    @State var day = initialDay

    UserAuth.setToken(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Ijg4ZTY5YmVlLTdmMmItNDY4OS1hNGUwLWNiMDI2NWQ2MDgxMyIsImVtYWlsIjoiYWxleGFuZHJlX3JvY2hAaG90bWFpbC5jb20iLCJpYXQiOjE3MzA0ODk5MzAsImV4cCI6MTczMDU3NjMzMH0.C8dviJ6KjFhfzL3Pe6t8k48jaj_51M8sraE3sJPn0_w")
    UserAuth.setUser(user: UserStruct(id: "1", name: "Alexandre", email: "alexandre@gmail.com", password: "123"))
    
    return CreateActionSheet(
        day: $day,
        actions: $actions
    )
}


