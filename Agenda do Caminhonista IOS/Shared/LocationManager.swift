import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder() // Instancia um geocoder

    @Published var location: CLLocation? // Última localização do usuário
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var city: String? // Nome da cidade
    @Published var country: String? // Nome do país

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() // Solicita permissão ao usuário
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation() // Começa a atualizar a localização
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation() // Para a atualização de localização
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last // Atualiza a localização com o último valor obtido
        
        // Chama a função para obter o nome da cidade e do país
        if let location = location {
            reverseGeocode(location: location)
        }
    }
    
    func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("Erro ao fazer geocodificação reversa: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("Nenhum placemark encontrado.")
                return
            }
            
            // Extrai o nome da cidade e do país
            self?.city = placemark.locality
            self?.country = placemark.country
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Erro ao obter a localização: \(error.localizedDescription)")
    }
}

