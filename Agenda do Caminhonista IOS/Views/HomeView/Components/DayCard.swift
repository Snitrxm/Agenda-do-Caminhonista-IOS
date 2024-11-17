//
//  DayCard.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 02/11/2024.
//

import SwiftUI

struct DayCard: View {
    @State var day: DayStruct
    
    init(day: DayStruct) {
        self.day = day
    }
    
    var departureAction: DayActionStruct? {
        day.actions?.first(where: { $0.action == "Partida" })
    }
    
    var arriveAction: DayActionStruct? {
        day.actions?.first(where: { $0.action == "Chegada" })
    }

    var breakActions: [DayActionStruct]? {
        day.actions?.filter { action in action.action.contains("Pausa")}
    }
    
    var next24HoursBreak: String? {
        guard let departureDateString = departureAction?.date else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Define o formato ISO 8601
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Converte a string para Date
        guard let departureDate = dateFormatter.date(from: departureDateString) else {
            print("Erro ao converter departureDateString para Date")
            return nil
        }
                
        // Adiciona 6 dias
        guard let nextBreakDate = Calendar.current.date(byAdding: .day, value: 6, to: departureDate) else {
            return nil
        }
        
        return DateUtils.format(nextBreakDate, format: "dd/MM/yy 'às' HH:mm")
    }

    
    var body: some View {
        GroupBox(label: HStack {
            if day.weekStart {
                Image(systemName: "star")
                    .foregroundColor(.yellow)
            }
            Text("\(DateUtils.format(day.date))")
        }, content: {
            VStack(alignment: .leading) {
                Text("Inicio da Semana: \(day.weekStart ? "Sim" : "Não")")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Local de Partida: \(departureAction?.local ?? "Não informado")")
                
                if let arrive = arriveAction {
                    Text("Local de Chegada: \(arrive.local)")
                }
                
                if let drivingMinutes = day.drivingMinutes {
                    Text("Horas de Condução: \(DateUtils.minutesToHours(drivingMinutes))")
                }
                
                if let next24HoursBreak = next24HoursBreak {
                    Text("Proxima Pausa de 24H: \(next24HoursBreak)")
                }
                
                Text("Amplitude 9H: \(DayUtils.handleGetAmplitude(day: day, type: "9H"))")
                Text("Amplitude 10H: \(DayUtils.handleGetAmplitude(day: day, type: "10H"))")
                
                if let departureKm = day.departureKm, let arriveKm = day.arriveKm {
                    Text("Total de KM Percorridos: \(DayUtils.handleCalculateTotalKm(departureKm: departureKm, arriveKm: arriveKm))")
                }
                
                if let breakActions = breakActions {
                    ForEach(breakActions, id: \.action) { action in
                        Text("\(action.action): Sim, Até \(DayUtils.handleCalculatePauseTime(action: action.action, whenActionWasCreated: action.createdAt))")
                    }
                }
            }
        })
        .groupBoxStyle(GroupBoxCardStyle())
        .background(
            NavigationLink("", destination: DayDetailsView(day: $day, initialTab: "Form"))
                .opacity(0)
        )
    }
}

#Preview {
    DayCard(day: DayStruct(
        id: "1",
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
        ))
}
