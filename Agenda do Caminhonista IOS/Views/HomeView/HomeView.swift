//
//  Home.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 28/10/2024.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

// Definindo a estrutura do PDF como FileDocument
struct PDFFile: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }
    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack {
                    if viewModel.isLoading {
                        VStack {
                            ProgressView()
                        }
                    }
                    
                    if viewModel.days.isEmpty && !viewModel.isLoading {
                        Text("Nenhum dia cadastrado")
                            .font(.headline)
                            .padding()
                    }
                    
                    if !viewModel.days.isEmpty && !viewModel.isLoading {
                        List(viewModel.days, id: \.id) { day in
                            DayCard(day: day)
                                .swipeActions(edge: .trailing) {
                                    Button() {
                                        viewModel.dayToDelete = day
                                        viewModel.isShowingDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(.red)
                                }
                                .swipeActions(edge: .leading) {
                                    NavigationLink(destination: DayDetailsView(day: $viewModel.days[viewModel.days.firstIndex(where: { $0.id == day.id })!], initialTab: "Actions")) {
                                        Label("Criar Ação", systemImage: "plus.circle")
                                            .tint(.blue)
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button(action: {
                                        viewModel.dayToCreatePdf = day
                                        viewModel.pdfData = viewModel.createPDF(day: day)
                                        viewModel.isOpenFileExporter = true
                                    }) {
                                        Label("Gerar PDF", systemImage: "doc")
                                            .tint(.green)
                                    }
                                }
                        }
                        .searchable(text: $viewModel.filterDaysText)
                        .listStyle(PlainListStyle())
                        .listRowSeparator(.hidden)
                    }
                }
                
                if !viewModel.isLoading {
                    BigButton(text: "Novo dia", isLoading: viewModel.isLoadingCreateDayButton, action: {
                        viewModel.createDay()
                    })
                        .padding()
                }
            }
            .fileExporter(isPresented: $viewModel.isOpenFileExporter, document: viewModel.pdfData.map { PDFFile(data: $0)} ?? nil, contentType: .pdf, defaultFilename: "Resumo do dia") { result in
                    switch result {
                    case .success:
                        viewModel.dayToCreatePdf = nil
                    case .failure(let error):
                        print(error)
                    }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        viewModel.isOpenWeeklyDrivingHoursSheet = true
                    }) {
                        Label("Weekly Hours", systemImage: "clock")
                    }
                }
                
                ToolbarItem {
                    Button(action: {
                        viewModel.isOpenSettingsSheet = true
                    }) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .navigationTitle("Home")
            .alert(isPresented: $viewModel.isShowingErrorAlert) {
                Alert(title: Text("Um erro aconteceu"), message: Text("\(viewModel.errorMessage)"))
            }
            .alert("Confirmar Exclusão", isPresented: $viewModel.isShowingDeleteConfirmation) {
                Button("Cancelar", role: .cancel) {}
                Button("Excluir", role: .destructive) {
                    if let day = viewModel.dayToDelete {
                        viewModel.handleDeleteDay(day: day)
                    }
                }
            } message: {
                Text("Tem certeza que deseja excluir este dia?")
            }
            .sheet(isPresented: $viewModel.isOpenSettingsSheet) {
                SettingsSheet()
            }
            .sheet(isPresented: $viewModel.isOpenWeeklyDrivingHoursSheet) {
                WeeklyDrivingHoursSheet()
            }
        }
        .onAppear(perform: viewModel.loadDays)
    }
}

#Preview {
    UserAuth.setToken(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Ijc2NjVlMzM2LTdkYjMtNGE3MS05MmRkLWE5MzhkZjQ5Y2Q2OCIsImVtYWlsIjoiYW5kcmVAZ21haWwuY29tIiwiaWF0IjoxNzMxODY3NzMyLCJleHAiOjE3MzE5NTQxMzJ9.q2q10tteTFlNbIwkfuOSVJHwWO185BQXtcaJEJ9cU-o")
    UserAuth.setUser(user: UserStruct(id: "7665e336-7db3-4a71-92dd-a938df49cd68", name: "Alexandre", email: "alexandre@gmail.com", password: "123"))
    
    return HomeView()
}
