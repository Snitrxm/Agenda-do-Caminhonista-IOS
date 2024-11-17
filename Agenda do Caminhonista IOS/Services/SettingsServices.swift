//
//  SettingsServices.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 07/11/2024.
//

class SettingsServices {
    private static let networkManager = NetworkManager()
    
    static func getAll(userId: String, completion: @escaping (Result<SettingsStruct, NetworkError>) -> Void) {
        networkManager.request(endpoint: "/settings/\(userId)", method: "GET", bearerToken: UserAuth.token) { (result: Result<SettingsStruct, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func update(settingsId: String, body: [String: Any], completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkManager.request(endpoint: "/settings/\(settingsId)", method: "PATCH", body: body, bearerToken: UserAuth.token) { (result: Result<Void, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
