import SwiftUI
import MapKit

struct MapSheet: View {
    var day: DayStruct
    @State private var directions: [MKRoute] = []
    @State private var isLoading = false
    
    var actionCoordinates: [CLLocationCoordinate2D] {
        day.actions?.compactMap { action in
            if let latitude = action.latitude, let longitude = action.longitude,
               let lat = Double(latitude), let lon = Double(longitude) {
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            return nil
        } ?? []
    }
    
    func fetchDirections() {
        guard actionCoordinates.count >= 2 else { return }
        
        var allRoutes: [MKRoute] = []
        
        // Calcula a rota entre cada par de pontos consecutivos
        for i in 0..<actionCoordinates.count - 1 {
            let start = actionCoordinates[i]
            let end = actionCoordinates[i + 1]
            
            let startPlacemark = MKPlacemark(coordinate: start)
            let endPlacemark = MKPlacemark(coordinate: end)
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: startPlacemark)
            request.destination = MKMapItem(placemark: endPlacemark)
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            
            isLoading = true
            directions.calculate { response, error in
                if let error = error {
                    print("Erro ao calcular direções: \(error.localizedDescription)")
                    isLoading = false
                    return
                }
                
                if let route = response?.routes.first {
                    allRoutes.append(route)
                }
                
                // Atualiza as direções quando todos os cálculos forem feitos
                if i == actionCoordinates.count - 2 {
                    self.directions = allRoutes
                    isLoading = false
                }
            }
        }
    }
    
    var body: some View {
        Map {
            ForEach(day.actions ?? [], id: \.id) { action in
                if let latitude = action.latitude, let longitude = action.longitude,
                   let lat = Double(latitude), let lon = Double(longitude) {
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    Marker(action.action, coordinate: coordinate)
                }
            }
            
            ForEach(directions, id: \.self) { route in
                MapPolyline(route.polyline)
                    .stroke(Color.blue, lineWidth: 4)
            }
        }
        .onAppear {
            fetchDirections()
        }
        .overlay {
            if isLoading {
                ProgressView("Calculando rota...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
    }
}

#Preview {
    @Previewable @State var day = DayStruct(
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
                            local: "Viana do Castelo - Portugal", latitude: "41.6932", longitude: "-8.8329", additionalInformations: "n Tem", createdAt: "2024-10-31T11:12:08.080Z", updatedAt: "2024-10-31T11:12:08.080Z"),
            DayActionStruct(id: "2", dayId: "1", action: "Pausa", date: "2024-10-31T13:00:08.080Z",
                            local: "A1 - Portugal", latitude: "41.5500", longitude: "-8.6000", additionalInformations: "Pausa", createdAt: "2024-10-31T13:00:08.080Z", updatedAt: "2024-10-31T13:00:08.080Z"),
            DayActionStruct(id: "3", dayId: "1", action: "Chegada", date: "2024-10-31T15:30:08.080Z",
                            local: "Porto - Portugal", latitude: "41.14961", longitude: "-8.61099", additionalInformations: "Entrega", createdAt: "2024-10-31T15:30:08.080Z", updatedAt: "2024-10-31T15:30:08.080Z")
        ]
    )
    
    return MapSheet(day: day)
}

