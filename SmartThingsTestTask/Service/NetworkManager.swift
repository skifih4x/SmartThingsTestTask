//
//  NetworkManager.swift
//  SmartThingsTestTask
//
//  Created by Артем Орлов on 07.07.2023.
//

import Foundation

protocol APIServiceProtocol: AnyObject {
    func fetchDevices(completion: @escaping (Result<[Device], Error>) -> Void)
    func deleteDevice(id: Int, completion: @escaping (Result<Void, Error>) -> Void)
    func performRequest(endpoint: APIEndpoint, completion: @escaping (Result<Data, Error>) -> Void)
}

enum APIError: Error {
    case invalidURL
    case noDataReceived
    case invalidResponse
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case unknownError
}

enum APIEndpoint {
    case getDevices
    case deleteDevice(id: Int)

    var url: URL? {
        switch self {
        case .getDevices:
            return URL(string: "https://api.fasthome.io/api/v1/test/devices")
        case .deleteDevice(let id):
            return URL(string: "https://api.fasthome.io/api/v1.1/test/devices/\(id)")
        }
    }

    var method: String {
        switch self {
        case .getDevices:
            return "GET"
        case .deleteDevice:
            return "DELETE"
        }
    }

    var headers: [String: String] {
        return ["Accept": "application/json"]
    }
}

class APIService: APIServiceProtocol {

    func fetchDevices(completion: @escaping (Result<[Device], Error>) -> Void) {
        performRequest(endpoint: .getDevices) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(DevicesResponse.self, from: data)
                    completion(.success(response.data))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteDevice(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = APIEndpoint.deleteDevice(id: id)
        performRequest(endpoint: endpoint) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    internal func performRequest(endpoint: APIEndpoint, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = endpoint.url else {
            let error = NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(.failure(error))
            return
        }

        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = endpoint.method
        request.allHTTPHeaderFields = endpoint.headers

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }

            completion(.success(data))
        }
        task.resume()
    }
}

