//
//  DateUtils.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 31/10/2024.
//

import Foundation

class DateUtils {
    static func toDate(from isoString: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return isoFormatter.date(from: isoString)
    }
    
    static func format(_ date: Date, format: String? = nil) -> String {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "Europe/Lisbon")
            formatter.dateFormat = format ?? "dd/MM/yy - EEEE" // Usa o formato padrão se 'format' for nil
            formatter.locale = Locale(identifier: "pt_BR")
            return formatter
        }()
        
        return dateFormatter.string(from: date)
    }
    
    static func format(_ dateString: String, format: String? = nil) -> String {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "Europe/Lisbon")
            formatter.dateFormat = format ?? "dd/MM/yy - EEEE" // Usa o formato padrão se 'format' for nil
            formatter.locale = Locale(identifier: "pt_BR")
            return formatter
        }()
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: dateString) {
            return dateFormatter.string(from: date)
        } else {
            return "Data inválida"
        }
    }
    
    static func minutesToHours(_ minutes: Int) -> String {
        let totalHours = minutes / 60
        let remainingMinutes = minutes % 60
        
        let formattedHours = String(format: "%02d", totalHours)
        let formattedMinutes = String(format: "%02d", remainingMinutes)
        
        return "\(formattedHours):\(formattedMinutes)"
    }
}
