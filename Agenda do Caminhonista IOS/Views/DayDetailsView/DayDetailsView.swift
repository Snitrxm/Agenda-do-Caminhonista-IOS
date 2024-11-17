import SwiftUI
import PhotosUI

struct DayDetailsView: View {
    @Binding var day: DayStruct
    @StateObject private var viewModel: DayDetailsViewModel
    @State private var selectedTab: String


    init(day: Binding<DayStruct>, initialTab: String) {
        _day = day
        _selectedTab = State(initialValue: initialTab)
        _viewModel = StateObject(wrappedValue: DayDetailsViewModel(day: day))
    }
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                form
                    .tabItem {
                        Label("Geral", systemImage: "doc.text.image")
                    }
                    .tag("Form" )
                   
                
                actionsTab
                    .tabItem {
                        Label("Ações", systemImage: "clock")
                    }
                    .tag("Actions")
                
                files
                    .tabItem {
                        Label("Files", systemImage: "doc")
                    }
                    .tag("Files")
            }
            .sheet(isPresented: $viewModel.isOpenMapSheet) {
                MapSheet(day: day)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationBackgroundInteraction(.enabled)
                    
            }
            .alert(isPresented: $viewModel.isShowingErrorAlert) {
                Alert(title: Text("Um erro aconteceu"), message: Text("\(viewModel.errorMessage)"))
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        viewModel.isOpenMapSheet = true
                    }) {
                        Label("map", systemImage: "map")
                    }
                }
                
//                ToolbarItem {
//                    Button(action: {
//                        viewModel.handleUpdateDay()
//                    }) {
//                        Text("Salvar")
//                    }
//                }
            }
            .onAppear {
                if selectedTab == "Actions" {
                    withAnimation {
                        viewModel.isShowingCreateActionSheet = true
                    }
                }
            }
            .navigationTitle("\(DateUtils.format(viewModel.day.date))")
        }
    }
    
    
    var files: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 1)
        
        return VStack {
            BigButton(text: "Adicionar Foto", isLoading: false, action: {
                viewModel.isOpenPhotosPickerSheet = true
            })
            .padding()
        
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.files, id: \.name) { file in
                        AsyncImage(url: URL(string: file.publicUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 300)
                            case .failure:
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .frame(width: 200, height: 200)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .onTapGesture {
                            viewModel.selectedPhoto = file
                            viewModel.isOpenPhotoDetail = true
                        }
                    }
                }
                .padding()
            }
            .scenePadding(.all)

            
            .sheet(isPresented: $viewModel.isOpenPhotoDetail) {
                if let photo = viewModel.selectedPhoto {
                    NavigationStack {
                        ZStack {
                            AsyncImage(url: URL(string: photo.publicUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                case .failure:
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .frame(width: 200, height: 200)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        .toolbar {
                            ToolbarItem {
                                Button(action:{
                                    viewModel.photoToDelete = photo
                                    viewModel.isOpenDeletePhotoConfirmationModal.toggle()
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .alert("Confirmar Exclusão", isPresented: $viewModel.isOpenDeletePhotoConfirmationModal) {
                Button("Cancelar", role: .cancel) {}
                Button("Excluir", role: .destructive) {
                    if let photo = viewModel.photoToDelete {
                        DayServices.deletePhoto(dayId: day.id, photoName: photo.name) { result in
                            switch result {
                            case .success:
                                DispatchQueue.main.async {
                                    viewModel.handleLoadDayFiles()
                                }
                            case .failure(let error):
                                print("Erro ao deletar fotos: \(error)")
                            }
                        }
                    }
                }
            } message: {
                Text("Tem certeza que deseja excluir essa foto?")
            }
            .photosPicker(isPresented: $viewModel.isOpenPhotosPickerSheet, selection: $viewModel.photosPickerItems)
            .onChange(of: viewModel.photosPickerItems) {
                Task {
                    var images: [UIImage] = []
                    
                    for item in viewModel.photosPickerItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            images.append(image)
                        }
                    }
                                        
                    if !images.isEmpty {
                        DayServices.uploadPhotos(dayId: day.id, photos: images) { result in
                            switch result {
                            case .success:
                                DispatchQueue.main.async {
                                    viewModel.handleLoadDayFiles()
                                }
                            case .failure(let error):
                                print("Erro ao enviar fotos: \(error)")
                            }
                        }
                    }
                    
                    viewModel.photosPickerItems.removeAll()
                }
            }
        }
        .task {
            viewModel.handleLoadDayFiles()
        }
        
    }
    
    
    var actionsTab: some View {
        ZStack(alignment: .bottom) {
            List(viewModel.actions, id: \.id) { action in
                GroupBox(label: Text("\(DateUtils.format(action.date, format: "dd/MM/yyyy - HH:mm"))"), content: {
                    VStack(alignment: .leading) {
                        Text("Ação: \(action.action)")
                        Text("Local: \(action.local)")
                        
                        if let additionalInformations = action.additionalInformations {
                            Text("Informações Adicionais: \(additionalInformations)")
                        }
                    }
                })
                .onTapGesture {
                    viewModel.actionToEdit = action
                    viewModel.isShowingEditActionSheet = true
                }
                .swipeActions(edge: .trailing) {
                    Button() {
                        viewModel.actionToDelete = action
                        viewModel.isShowingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
                .groupBoxStyle(GroupBoxCardStyle())
            }
            .listStyle(PlainListStyle())
            .listRowSeparator(.hidden)
            
            
            BigButton(text: "Nova Ação", isLoading: false, action: {
                viewModel.isShowingCreateActionSheet = true
            })
            .padding()
        }
        .sheet(isPresented: $viewModel.isShowingCreateActionSheet) {
            CreateActionSheet(day: $viewModel.day, actions: $viewModel.actions)
        }
        .sheet(isPresented: $viewModel.isShowingEditActionSheet) {
            if let actionToEdit = viewModel.actionToEdit {
                EditActionSheet(
                    actions: $viewModel.actions,
                    actionToEdit: Binding(
                        get: { actionToEdit },
                        set: { viewModel.actionToEdit = $0 }
                    )
                )
            }
        }
        .alert("Confirmar Exclusão", isPresented: $viewModel.isShowingDeleteConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Excluir", role: .destructive) {
                if let action = viewModel.actionToDelete {
                    viewModel.handleDeleteAction(action: action)
                }
            }
        } message: {
            Text("Tem certeza que deseja excluir essa ação?")
        }
    }

    
    var form: some View {
        Form {
            Section(header: Text("Informações Gerais")) {
                Toggle("Início da Semana", isOn: $viewModel.formData.weekStart)
            }
            
            Section(header: Text("Caminhão")) {
                LabeledContent {
                    TextField("Placa do Trator", text: $viewModel.formData.truckPlate)
                } label: {
                    Text("Placa do Trator:")
                }
                
                LabeledContent {
                    TextField("Placa do Reboque", text: $viewModel.formData.trailerPlate)
                } label: {
                    Text("Placa do Reboque:")
                }
            }
            
            Section(header: Text("Kilometros")) {
                VStack(alignment: .leading, spacing: 10) {
                    LabeledContent {
                        TextField("KM de Partida:", text: $viewModel.formData.departureKm)
                            .keyboardType(.numberPad)
                    } label: {
                        Text("KM de Partida:")
                    }
                    
                    Divider()
                    
                    LabeledContent {
                        TextField("KM de Chegada:", text: $viewModel.formData.arriveKm)
                            .keyboardType(.numberPad)
                    } label: {
                        Text("KM de Chegada:")
                    }
                    
                    Text("Total de KM Percorridos: \(viewModel.totalKmDrived)")
                        .font(.footnote)
                        .foregroundColor(Color.black.opacity(0.5))
                }
            }
            
            Section(header: Text("Amplitudes")) {
                Text("Amplitude 9H: \(DayUtils.handleGetAmplitude(day: viewModel.day, type: "9H"))")
                Text("Amplitude 10H: \(DayUtils.handleGetAmplitude(day: viewModel.day, type: "10H"))")
            }
            
            Section(header: Text("Horas de Condução")) {
                DatePicker("Horas de Condução", selection: $viewModel.formData.drivingTime, displayedComponents: [.hourAndMinute])
                    .onAppear {
                        viewModel.formData.drivingTime = Calendar.current.date(bySettingHour: viewModel.formData.drivingMinutes / 60,
                                                                               minute: viewModel.formData.drivingMinutes % 60,
                                                                        second: 0,
                                                                        of: Date()) ?? Date()
                    }
                    .onChange(of: viewModel.formData.drivingTime) { newDate in
                                    let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                    if let hour = components.hour, let minute = components.minute {
                                        viewModel.formData.drivingMinutes = (hour * 60) + minute
                                    }
                                }
            }
            
            Section(header: Text("Observações")) {
                TextEditor(text: $viewModel.formData.observations)
            }
        }
        .onChange(of: viewModel.formData) {
            viewModel.handleUpdateDay()
        }
    }
}

#Preview {
    @Previewable @State var day = DayStruct(
        id: "8921329a-1b97-4d07-93a9-1ac5ea68d3de",
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
        actions: [
            DayActionStruct(id: "1", dayId: "1", action: "Partida", date: "2024-10-31T11:12:08.080Z",
                            local: "Viana do Castelo - Portugal", latitude: "37.3347302", longitude: "-122.0089189", additionalInformations: "n Tem", createdAt: "2024-10-31T11:12:08.080Z", updatedAt: "2024-10-31T11:12:08.080Z")
        ]
        )
    
    UserAuth.setToken(token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Ijc2NjVlMzM2LTdkYjMtNGE3MS05MmRkLWE5MzhkZjQ5Y2Q2OCIsImVtYWlsIjoiYW5kcmVAZ21haWwuY29tIiwiaWF0IjoxNzMxODQwODk2LCJleHAiOjE3MzE5MjcyOTZ9.ghyuS_oag-xcb3pTxe17xdf2df9sQw5c8rFIG-UVcvY")
    
    return DayDetailsView(day: $day, initialTab: "Form")
}

