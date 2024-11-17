//
//  DayDetailsViewModel.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 13/11/2024.
//

import Foundation
import SwiftUI
import Combine
import _PhotosUI_SwiftUI

struct DayFormData: Equatable {
    var weekStart: Bool
    var truckPlate: String
    var trailerPlate: String
    var departureKm: String
    var arriveKm: String
    var drivingMinutes: Int
    var drivingTime: Date
    var observations: String
}

class DayDetailsViewModel: ObservableObject {
    @Binding var day: DayStruct
    @Published var actions: [DayActionStruct] = []
    @Published var formData: DayFormData {
        didSet {
            if formData.departureKm != oldValue.departureKm || formData.arriveKm != oldValue.arriveKm {
                objectWillChange.send()
            }
        }
    }
    @Published var isShowingCreateActionSheet: Bool = false
    @Published var isShowingEditActionSheet: Bool = false
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var actionToDelete: DayActionStruct?
    @Published var actionToEdit: DayActionStruct?
    @Published var isShowingDeleteConfirmation: Bool = false
    @Published var isOpenMapSheet: Bool = false
    @Published var photosPickerItems: [PhotosPickerItem] = []
    @Published var isOpenPhotosPickerSheet: Bool = false
    @Published var isOpenPhotoDetail: Bool = false
    @Published var selectedPhoto: FileStruct?
    @Published var files: [FileStruct] = []
    @Published var photoToDelete: FileStruct?
    @Published var isOpenDeletePhotoConfirmationModal: Bool = false

    
    var totalKmDrived: Int {
        return DayUtils.handleCalculateTotalKm(departureKm: Int(formData.departureKm) ?? 0, arriveKm: Int(formData.arriveKm) ?? 0)
    }
    
    init(day: Binding<DayStruct>) {
        _day = day
        self.actions = day.wrappedValue.actions ?? []
        _formData = Published(initialValue: DayFormData(
            weekStart: day.wrappedValue.weekStart,
            truckPlate: day.wrappedValue.truckPlate ?? "",
            trailerPlate: day.wrappedValue.trailerPlate ?? "",
            departureKm: day.wrappedValue.departureKm != nil ? String(day.wrappedValue.departureKm!) : "",
            arriveKm: day.wrappedValue.arriveKm != nil ? String(day.wrappedValue.arriveKm!) : "",
            drivingMinutes: day.wrappedValue.drivingMinutes ?? 0,
            drivingTime: Date(),
            observations: day.wrappedValue.observations ?? ""
        ))
    }
    
    func handleDeleteAction(action: DayActionStruct) {
        ActionsServices.delete(actionId: action.id) { (result: Result<Void, NetworkError>) in
            switch result {
            case .success():
                withAnimation {
                    if let index = self.actions.firstIndex(where: { $0.id == action.id }) {
                        self.actions.remove(at: index)
                        self.day.actions?.remove(at: index)
                    }
                }
            case .failure(let error):
                self.isShowingErrorAlert = true
                self.errorMessage = error.getErrorMessage()
            }
        }
    }
    
    func handleLoadDayFiles() {
        DayServices.getFilesByDayId(dayId: day.id) { (result: Result<[FileStruct], NetworkError>) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.files = response
                }
            case .failure(let error):
                print(error)
            }
        }

    }
    
    func handleUpdateDay() {
        let body: [String: Any] = [
            "truckPlate": formData.truckPlate,
            "trailerPlate": formData.trailerPlate,
            "departureKm": Int(formData.departureKm) ?? 0,
            "arriveKm": Int(formData.arriveKm) ?? 0,
            "drivingMinutes": formData.drivingMinutes,
            "observations": formData.observations,
            "weekStart": formData.weekStart
        ]
        day.truckPlate = formData.truckPlate
        day.trailerPlate = formData.trailerPlate
        day.departureKm = Int(formData.departureKm) ?? 0
        day.arriveKm = Int(formData.arriveKm) ?? 0
        day.drivingMinutes = formData.drivingMinutes
        day.observations = formData.observations
        day.weekStart = formData.weekStart
        
        DayServices.update(dayId: day.id, body: body) { (result: Result<DayStruct, NetworkError>) in
            switch result {
                case .success:
                    break
                case .failure(let error):
                    self.isShowingErrorAlert = true
                    self.errorMessage = error.getErrorMessage()
            }
        }
    }
    
    
}
