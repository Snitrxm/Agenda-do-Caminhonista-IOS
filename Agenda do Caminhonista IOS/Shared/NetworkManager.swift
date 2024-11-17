import Foundation
import UniformTypeIdentifiers
import UIKit

// Enum para os tipos de erros de requisição
enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
    case noData
}

extension NetworkError {
    func getErrorMessage() -> String {
        switch self {
        case .requestFailed(let nsError as NSError):
            return nsError.localizedDescription
        case .invalidURL:
            return "URL inválida."
        case .noData:
            return "Nenhum dado recebido do servidor."
        case .decodingFailed:
            return "Falha ao decodificar a resposta do servidor."
        }
    }
}

class NetworkManager {
    // let baseURL = "http://100.28.23.135:3000"
    let baseURL = "http://localhost:3000"
    
    func uploadFiles(endpoint: String,
                    files: [URL],
                    bearerToken: String?,
                    completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let fileData = files.compactMap { fileURL -> (data: Data, name: String, mimeType: String)? in
            guard let data = try? Data(contentsOf: fileURL) else { return nil }
            let mimeType = mimeTypeForPath(fileURL.path) ?? "application/octet-stream"
            return (data: data, name: fileURL.lastPathComponent, mimeType: mimeType)
        }
        
        upload(endpoint: endpoint, files: fileData, bearerToken: bearerToken, completion: completion)
    }
    
    private func mimeTypeForPath(_ path: String) -> String? {
        let pathExtension = (path as NSString).pathExtension
        guard !pathExtension.isEmpty else { return nil }
        
        if let utType = UTType(filenameExtension: pathExtension),
           let mimeType = utType.preferredMIMEType {
            return mimeType
        }
        
        return "application/octet-stream" // MIME type genérico para arquivos desconhecidos
    }
    
    func uploadPhotos(endpoint: String,
                     photos: [UIImage],
                     bearerToken: String?,
                     completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let files = photos.compactMap { photo -> (data: Data, name: String, mimeType: String)? in
            guard let imageData = photo.jpegData(compressionQuality: 0.8) else { return nil }
            return (data: imageData, name: "\(UUID().uuidString).jpg", mimeType: "image/jpeg")
        }
        
        upload(endpoint: endpoint, files: files, bearerToken: bearerToken, completion: completion)
    }
    
    private func upload(endpoint: String,
                        files: [(data: Data, name: String, mimeType: String)],
                        bearerToken: String?,
                        completion: @escaping (Result<Void, NetworkError>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = bearerToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        
        for file in files {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files\"; filename=\"\(file.name)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(file.mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(file.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode > 299 {
                completion(.failure(.requestFailed(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Request failed with status code \(httpResponse.statusCode)"]))))
                return
            }
            
            completion(.success(()))
        }
        
        task.resume()
    }



    // Método para chamadas que esperam um retorno do tipo `Decodable`
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        bearerToken: String? = nil,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = bearerToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                completion(.failure(.requestFailed(error)))
                return
            }
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode > 299 {
                if let data = data {
                    if let jsonError = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = jsonError["message"] as? String {
                        let backendError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        completion(.failure(.requestFailed(backendError)))
                    } else if let errorMessage = String(data: data, encoding: .utf8) {
                        let backendError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        completion(.failure(.requestFailed(backendError)))
                    } else {
                        let genericError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Request failed with status code \(httpResponse.statusCode)"])
                        completion(.failure(.requestFailed(genericError)))
                    }
                } else {
                    completion(.failure(.noData))
                }
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }

        task.resume()
    }

    // Método de sobrecarga para `Void`
    func request(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        bearerToken: String? = nil,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = bearerToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                completion(.failure(.requestFailed(error)))
                return
            }
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode > 299 {
                if let data = data {
                    if let jsonError = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = jsonError["message"] as? String {
                        let backendError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                            completion(.failure(.requestFailed(backendError)))
                        } else if let errorMessage = String(data: data, encoding: .utf8) {
                            let backendError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                            completion(.failure(.requestFailed(backendError)))
                        } else {
                            let genericError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Request failed with status code \(httpResponse.statusCode)"])
                            completion(.failure(.requestFailed(genericError)))
                        }
                } else {
                    completion(.failure(.noData))
                }
                return
            }

            completion(.success(())) // Retorna `Void` sem tentar decodificar os dados
        }

        task.resume()
    }
}

