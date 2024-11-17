//
//  ActionsServices.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 04/11/2024.
//
class ActionsServices {
    private static let networkManager = NetworkManager()
    
    static func delete(actionId: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkManager.request(endpoint: "/days/actions/\(actionId)", method: "DELETE", bearerToken: UserAuth.token) { (result: Result<Void, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func update(actionId: String, body: [String: Any], completion: @escaping (Result<DayActionStruct, NetworkError>) -> Void) {
        networkManager.request(endpoint: "/days/actions/\(actionId)", method: "PATCH", body: body, bearerToken: UserAuth.token) { (result: Result<DayActionStruct, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
