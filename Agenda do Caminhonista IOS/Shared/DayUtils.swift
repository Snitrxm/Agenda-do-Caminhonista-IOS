//
//  DayUitls.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 31/10/2024.
//

import Foundation

class DayUtils {
    static func handleCalculatePauseTime(action: String, whenActionWasCreated: String? = nil) -> String {
        var result: Date
        if let dateString = whenActionWasCreated {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = isoFormatter.date(from: dateString) {
                result = date
            } else {
                result = Date() // Fallback para data atual
            }
        } else {
            result = Date() // Fallback para data atual
        }
        
        // Manipulação de data com base na ação
        let calendar = Calendar.current
        
        switch action {
        case "Pausa 45M":
            result = calendar.date(byAdding: .minute, value: 45, to: result) ?? result
        case "Pausa 9H":
            result = calendar.date(byAdding: .hour, value: 9, to: result) ?? result
        case "Pausa 11H":
            result = calendar.date(byAdding: .hour, value: 11, to: result) ?? result
        case "Pausa 24H":
            result = calendar.date(byAdding: .hour, value: 24, to: result) ?? result
        case "Pausa 45H":
            result = calendar.date(byAdding: .hour, value: 45, to: result) ?? result
        case "Pausa 45H + Compensação 21H":
            result = calendar.date(byAdding: .hour, value: 66, to: result) ?? result
        case "Pausa 45H + 2 Compensações 21H":
            result = calendar.date(byAdding: .hour, value: 87, to: result) ?? result
        default:
            break
        }

        return DateUtils.format(result, format: "dd/MM/yyyy - HH:mm:ss")
    }
    
    static func handleCalculateTotalKm(departureKm: Int, arriveKm: Int) -> Int {
        return arriveKm - departureKm
    }
    
    static func handleGetAmplitude(day: DayStruct, type: String) -> String {
        guard type == "9H" || type == "10H" else {
            return "Tipo inválido"
        }

        guard let departureAction = day.actions?.first(where: { $0.action == "Partida" }),
              let departureDate = DateUtils.toDate(from: departureAction.date) else {
            return "Crie uma ação de Partida para calcular a amplitude"
        }

        let amplitudeDate = Calendar.current.date(byAdding: .hour, value: (type == "9H" ? 15 : 13), to: departureDate) ?? departureDate
        
        return DateUtils.format(amplitudeDate, format: "dd/MM/yyyy - HH:mm:ss")
    }
}
