//
//  SettingsSheetViewModel.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 14/11/2024.
//

import Foundation

struct FormDataStruct {
    var id: String
    var defaultTruckPlate: String
    var defaultTrailerPlate: String
}

class SettingsSheetViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isLoadingSaveButton: Bool = false
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var formData: FormDataStruct
    @Published var successfullySaved: Bool = false
    
    init() {
        _formData = Published(initialValue: FormDataStruct(id: "", defaultTruckPlate: "", defaultTrailerPlate: ""))
    }
    
    func handleLoadSettings() {
        isLoading = true
        if let id = UserAuth.user?.id {
            SettingsServices.getAll(userId: id) { (result: Result<SettingsStruct, NetworkError>) in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success(let response):
                        self.formData.id = response.id
                        self.formData.defaultTruckPlate = response.defaultTruckPlate ?? ""
                        self.formData.defaultTrailerPlate = response.defaultTrailerPlate ?? ""
                    case .failure(let error):
                        self.isLoading = false
                        self.isShowingErrorAlert = true
                        self.errorMessage = error.getErrorMessage()
                    }
                }
            }
        }
    }
    
    func handleUpdateSettings() {
        isLoadingSaveButton = true
        let body: [String: Any] = [
            "defaultTruckPlate": formData.defaultTruckPlate,
            "defaultTrailerPlate": formData.defaultTrailerPlate
        ]
        
        SettingsServices.update(settingsId: formData.id, body: body) { (result: Result<Void, NetworkError>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(_):
                    self.isLoadingSaveButton = false
                    self.successfullySaved = true
                case .failure(let error):
                    self.isLoadingSaveButton = false
                    self.isShowingErrorAlert = true
                    self.errorMessage = error.getErrorMessage()
                }
            }
        }
    }
}
