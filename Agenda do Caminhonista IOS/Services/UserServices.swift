//
//  DayServices.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 02/11/2024.
//

struct LoginResponse: Encodable, Decodable {
    let token: String
    let user: UserStruct
}

class UserServices {
    private static let networkManager = NetworkManager()
    
    static func login(body: [String: String], completion: @escaping (Result<LoginResponse, NetworkError>) -> Void) {
        networkManager.request(endpoint: "/users/login", method: "POST", body: body) { (result: Result<LoginResponse, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

