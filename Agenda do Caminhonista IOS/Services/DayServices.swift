//
//  DayServices.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 02/11/2024.
//

import Foundation
import UIKit



class DayServices {
    private static let networkManager = NetworkManager()
    
    static func deletePhoto(dayId: String, photoName: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkManager.request(endpoint: "/days/\(dayId)/files/\(photoName)", method: "DELETE", bearerToken: UserAuth.token) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func uploadPhotos(dayId: String, photos: [UIImage], completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkManager.uploadPhotos(endpoint: "/days/\(dayId)/files", photos: photos, bearerToken: UserAuth.token) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func getFilesByDayId(dayId: String, completion: @escaping (Result<[FileStruct], NetworkError>) -> Void) {
        networkManager.request(endpoint: "/days/\(dayId)/files", method: "GET", bearerToken: UserAuth.token) { (result: Result<[FileStruct], NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func getAll(completion: @escaping (Result<[DayStruct], NetworkError>) -> Void) {
        networkManager.request(endpoint: "/days", method: "GET", bearerToken: UserAuth.token) { (result: Result<[DayStruct], NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func getWeeklyDrivingHours(completion: @escaping (Result<[WeeklyDrivingHoursStruct], NetworkError>) -> Void) {
        networkManager.request(endpoint: "/days/week/hours", method: "GET", bearerToken: UserAuth.token) { (result: Result<[WeeklyDrivingHoursStruct], NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func create(body: [String: Any], completion: @escaping (Result<DayStruct, NetworkError>) -> Void) {
        networkManager.request(endpoint: "/days", method: "POST", body: body, bearerToken: UserAuth.token) { (result: Result<DayStruct, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func update(dayId: String, body: [String: Any], completion: @escaping (Result<DayStruct, NetworkError>) -> Void) {
        networkManager.request(endpoint: "/days/\(dayId)", method: "PATCH", body: body, bearerToken: UserAuth.token) { (result: Result<DayStruct, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func delete(dayId: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        networkManager.request(endpoint: "/days/\(dayId)", method: "DELETE", bearerToken: UserAuth.token) { (result: Result<Void, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

