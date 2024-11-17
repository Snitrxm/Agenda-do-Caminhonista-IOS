//
//  EditActionSheet.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 11/11/2024.
//

import SwiftUI



struct EditActionSheet: View {
    @Environment(\.dismiss) private var dimiss
    
    @StateObject private var viewModel: EditActionViewModel
    @Binding var actionToEdit: DayActionStruct
    @Binding var actions: [DayActionStruct]
    
    
    init(actions: Binding<[DayActionStruct]> ,actionToEdit: Binding<DayActionStruct>) {
        _actions = actions
        _actionToEdit = actionToEdit
        _viewModel = StateObject(wrappedValue: .init(actions: actions, actionToEdit: actionToEdit))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Local")) {
                        TextField("Local", text: $viewModel.formData.local)
                    }
                    
                    Section(header: Text("Hora")) {
                        DatePicker("Hora", selection: $viewModel.formData.date, displayedComponents: [.hourAndMinute])
                    }
                }
            }
            .onChange(of: viewModel.successfullySaved) {
                if viewModel.successfullySaved {
                    dimiss()
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        viewModel.handleUpdateAction()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.blue)
                        } else {
                            Text("Salvar")
                        }
                    }
                }
            }
            .navigationTitle("Editar Ação")
        }
    }
}

#Preview {
    @Previewable @State var action = DayActionStruct(id: "1", dayId: "1", action: "Partida", date: "2024-10-31T11:12:08.080Z",
                                                     local: "Viana do Castelo - Portugal", latitude: "37.3347302", longitude: "-122.0089189", additionalInformations: "n Tem", createdAt: "2024-10-31T11:12:08.080Z", updatedAt: "2024-10-31T11:12:08.080Z")

    @Previewable @State var actions = [DayActionStruct(id: "1", dayId: "1", action: "Partida", date: "2024-10-31T11:12:08.080Z",
                                                       local: "Viana do Castelo - Portugal", latitude: "37.3347302", longitude: "-122.0089189", additionalInformations: "n Tem", createdAt: "2024-10-31T11:12:08.080Z", updatedAt: "2024-10-31T11:12:08.080Z")]
    
    return EditActionSheet(actions: $actions, actionToEdit: $action)
        
}
