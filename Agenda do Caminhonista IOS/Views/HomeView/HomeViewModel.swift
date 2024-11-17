//
//  HomeViewModel.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 13/11/2024.
//

import Foundation
import SwiftUI
import PDFKit

class HomeViewModel: ObservableObject {
    @Published var days: [DayStruct] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingCreateDayButton: Bool = false
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var dayToDelete: DayStruct?
    @Published var isShowingDeleteConfirmation: Bool = false
    @Published var isOpenSettingsSheet: Bool = false
    @Published var isOpenWeeklyDrivingHoursSheet: Bool = false
    @Published var pdfData: Data?
    @Published var isOpenFileExporter: Bool = false
    @Published var dayToCreatePdf: DayStruct?
    @Published var filterDaysText: String = ""
    
    var filteredDays: [DayStruct] {
        guard !filterDaysText.isEmpty else { return days }
        return days.filter { $0.date.localizedCaseInsensitiveContains(filterDaysText)}
    }
    
    
    func createParagraphStyle(alignment: NSTextAlignment) -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        return paragraphStyle
    }
    
    func createPDF(day: DayStruct) -> Data? {
        let pdfData = NSMutableData()
        let pdfMetaData = [
            kCGPDFContextCreator: "Agenda do Caminhonista",
            kCGPDFContextAuthor: "Seu Nome"
        ]
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, pdfMetaData)
        UIGraphicsBeginPDFPage()
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Tamanho da largura da página
        let pageWidth: CGFloat = 612 // Largura total de uma página Letter
        var currentY: CGFloat = 20 // Posição vertical inicial
        
        // Configurar título
        let title = "Resumo do dia \(DateUtils.format(day.date))"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .paragraphStyle: createParagraphStyle(alignment: .center)
        ]
        title.draw(in: CGRect(x: 20, y: currentY, width: pageWidth - 40, height: 30), withAttributes: titleAttributes)
        currentY += 40
        
        // Desenhar os detalhes da struct
        let details = """
        ID: \(day.id)
        Data: \(DateUtils.format(day.date))
        Inicio da Semana: \(day.weekStart ? "Sim" : "Não")
        KM Inicial: \(day.departureKm ?? 0)
        KM Final: \(day.arriveKm ?? 0)
        KM Total: \(DayUtils.handleCalculateTotalKm(departureKm: day.departureKm ?? 0, arriveKm: day.arriveKm ?? 0))
        Minutos Dirigindo: \(day.drivingMinutes ?? 0)
        Placa do Caminhão: \(day.truckPlate ?? "N/A")
        Placa do Reboque: \(day.trailerPlate ?? "N/A")
        Observações: \(day.observations ?? "Sem observações")
        """
        
        let detailsAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .paragraphStyle: createParagraphStyle(alignment: .left)
        ]
        details.draw(in: CGRect(x: 20, y: currentY, width: pageWidth - 40, height: 200), withAttributes: detailsAttributes)
        currentY += 220
        
        // Título das ações
        let actionTitle = "Ações"
        let actionTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .paragraphStyle: createParagraphStyle(alignment: .center)
        ]
        actionTitle.draw(in: CGRect(x: 20, y: currentY, width: pageWidth - 40, height: 30), withAttributes: actionTitleAttributes)
        currentY += 40
        
        // Listar as ações
        if let actions = day.actions {
            for action in actions {
                let actionDetails = """
                Ação: \(action.action)
                Data: \(DateUtils.format(action.date))
                Local: \(action.local)
                Informações: \(action.additionalInformations ?? "")
                """
                
                let actionDetailsAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16),
                    .paragraphStyle: createParagraphStyle(alignment: .left)
                ]
                actionDetails.draw(in: CGRect(x: 20, y: currentY, width: pageWidth - 40, height: 100), withAttributes: actionDetailsAttributes)
                currentY += 120
            }
        }
        
        UIGraphicsEndPDFContext()
        return pdfData as Data
    }

    func loadDays() {
        isLoading = true
        DayServices.getAll { (result: Result<[DayStruct], NetworkError>) in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    self.days = response
                case .failure(let error):
                    self.isLoading = false
                    self.isShowingErrorAlert = true
                    self.errorMessage = error.getErrorMessage()
                }
            }
        }
    }
    
    func createDay() {
        isLoadingCreateDayButton = true
    
        let body: [String: Any] = [
            "date": Date().formatted(.iso8601),
        ]
        
        DayServices.create(body: body) { (result: Result<DayStruct, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let newDay):
                    self.isLoadingCreateDayButton = false
                    withAnimation {
                        self.days.append(newDay)
                    }
                case .failure(let error):
                    self.isLoadingCreateDayButton = false
                    self.isShowingErrorAlert = true
                    self.errorMessage = error.getErrorMessage()
                }
            }
        }
    }
    
    func handleDeleteDay(day: DayStruct) {
        DayServices.delete(dayId: day.id) { (result: Result<Void, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    withAnimation {
                        self.days = self.days.filter { $0.id != day.id }
                    }
                case .failure(let error):
                    self.isShowingErrorAlert = true
                    self.errorMessage = error.getErrorMessage()
                }
            }
        }
    }
}
