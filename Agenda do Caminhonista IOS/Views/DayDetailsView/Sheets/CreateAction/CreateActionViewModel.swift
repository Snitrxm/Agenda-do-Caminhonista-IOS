//
//  CreateActionViewModel.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 13/11/2024.
//

import Foundation
import SwiftUICore

class CreateActionViewModel: ObservableObject {
    @ObservedObject var locationManager = LocationManager()

    @Binding var day: DayStruct
    @Binding var actions: [DayActionStruct]
    @Published var selectedAction: String = ""
    @Published var local: String = ""
    @Published var additionalInformations: String = ""
    @Published var isLoading: Bool = false
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var didCreateAction: Bool = false
    
    var actionsList: [String] = [
        "Partida",
        "Chegada",
        "Pausa 15M",
        "Pausa 30M",
        "Pausa 45M",
        "Pausa 9H",
        "Pausa 11H",
        "Pausa 24H",
        "Pausa 45H",
        "Pausa 45H + Compensação 21H",
        "Pausa 45H + 2 Compensações 21H",
        "Carregamento",
        "Descarga",
        "Abastecimento",
        "Outros"
    ]
    
    init(day: Binding<DayStruct>, actions: Binding<[DayActionStruct]>, locationManager: LocationManager){
        _day = day
        _actions = actions
        _locationManager = ObservedObject(wrappedValue: locationManager)
        selectedAction = actionsList.first ?? ""
    }
    
    func handleCreateAction(){
        isLoading = true
        let networkManager = NetworkManager()
        
        let body: [String: Any] = [
            "action": selectedAction,
            "date": Date().formatted(.iso8601),
            "additionalInformations": additionalInformations,
            "local": local,
            "latitude": String(locationManager.location?.coordinate.latitude ?? 0),
            "longitude": String(locationManager.location?.coordinate.longitude ?? 0)
        ]
                
        networkManager.request(endpoint: "/days/\(self.day.id)/actions", method: "POST", body: body, bearerToken: UserAuth.token) { (result: Result<CreateActionResponse, NetworkError>) in
            switch result {
            case .success(let response):
                self.actions.append(DayActionStruct(id: response.id, dayId: self.day.id, action: response.action, date: response.date, local: response.local,
                                                    latitude: response.latitude, longitude: response.longitude ,additionalInformations: response.additionalInformations, createdAt: response.createdAt, updatedAt: response.updatedAt))
                self.day.actions = self.actions
                self.isLoading = false
                self.didCreateAction = true
            case .failure(let error):
                self.isLoading = false
                self.isShowingErrorAlert = true
                self.errorMessage = error.getErrorMessage()
            }
        }
    }
    
    func updateLocal() {
        local = "\(locationManager.city ?? "") - \(locationManager.country ?? "")"
    }
}
