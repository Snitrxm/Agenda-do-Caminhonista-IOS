//
//  SettingsSheet.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 07/11/2024.
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) var dimiss
    
    @StateObject private var viewModel = SettingsSheetViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                }
                
                if !viewModel.isLoading {
                    Form {
                        Section(header: Text("Caminhão")) {
                            LabeledContent {
                                TextField("Placa do Trator", text: $viewModel.formData.defaultTruckPlate)
                            } label: {
                                Text("Placa do Trator:")
                            }
                            
                            LabeledContent {
                                TextField("Placa do Reboque", text: $viewModel.formData.defaultTrailerPlate)
                            } label: {
                                Text("Placa do Reboque:")
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action:{
                        viewModel.handleUpdateSettings()
                    }) {
                        if viewModel.isLoadingSaveButton {
                            ProgressView()
                                .tint(.blue)
                        } else {
                            Text("Salvar")
                        }
                    }
                }
            }
            .alert(isPresented: $viewModel.isShowingErrorAlert) {
                Alert(title: Text("Um erro aconteceu"), message: Text("\(viewModel.errorMessage)"))
            }
            .navigationTitle("Configurações")
        }
        .onChange(of: viewModel.successfullySaved) {
            if viewModel.successfullySaved {
                dimiss()
            }
        }
        .task {
            viewModel.handleLoadSettings()
        }
    }
}

#Preview {
    UserAuth.setToken(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Ijc2NjVlMzM2LTdkYjMtNGE3MS05MmRkLWE5MzhkZjQ5Y2Q2OCIsImVtYWlsIjoiYW5kcmVAZ21haWwuY29tIiwiaWF0IjoxNzMxNTI0MDkyLCJleHAiOjE3MzE2MTA0OTJ9.zMTDbAbCPRzhTvXQSNFkzwSIxcZ4vu7_l9QiraRvTk8")
    UserAuth.setUser(user: UserStruct(id: "7665e336-7db3-4a71-92dd-a938df49cd68", name: "Alexandre", email: "alexandre@gmail.com", password: "123"))
    
    return SettingsSheet()
}
