//
//  EdtiActionViewModel.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 14/11/2024.
//

import Foundation
import SwiftUICore

struct FormData {
    var local: String
    var date: Date
}

class EditActionViewModel: ObservableObject {
    @Binding var actions: [DayActionStruct]
    @Binding var actionToEdit: DayActionStruct
    @Published var formData: FormData
    @Published var successfullySaved: Bool = false
    @Published var isLoading: Bool = false
    
    init(actions: Binding<[DayActionStruct]>,actionToEdit: Binding<DayActionStruct>) {
        _actions = actions
        _actionToEdit = actionToEdit
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        _formData = Published(initialValue: FormData(local: actionToEdit.wrappedValue.local,
                                                      date: isoFormatter.date(from: actionToEdit.wrappedValue.date) ?? Date()))
    }
    
    func handleUpdateAction() {
        isLoading = true
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
        let body = [
            "local": formData.local,
            "date": isoFormatter.string(from: self.formData.date),
        ]
        
        ActionsServices.update(actionId: actionToEdit.id, body: body) { (result: Result<DayActionStruct, NetworkError>) in
            switch result {
            case .success:
                var updatedAction = self.actionToEdit
                updatedAction.local = self.formData.local
                updatedAction.date = isoFormatter.string(from: self.formData.date)
                
                self.actionToEdit = updatedAction
                
                if let index = self.actions.firstIndex(where: { $0.id == self.actionToEdit.id }) {
                    self.actions[index] = updatedAction
                }
                self.isLoading = false
                self.successfullySaved = true
            case .failure(let error):
                self.isLoading = false
                print(error)
            }
        }
    }
}
