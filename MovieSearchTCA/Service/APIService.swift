//
//  APIService.swift
//  MovieSearchTCA
//
//  Created by Manuel Loigeret on 2023-11-12.
//

import Foundation

protocol APIServiceProtocol {
    func request<T: Decodable>(url: URL, expecting: T.Type) async -> Result<T, APIError>
    static func make() -> APIServiceProtocol
}

class APIService: APIServiceProtocol {
    static func make() -> APIServiceProtocol {
        return APIService()
    }
    
    func request<T: Decodable>(url: URL, expecting: T.Type) async -> Result<T, APIError> {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return .success(decodedResponse)
        } catch {
            return .failure(APIError(underlyingError: error))
        }
    }
}

struct APIError: Error, Equatable {
    let underlyingError: Error

    static func ==(lhs: APIError, rhs: APIError) -> Bool {
        return lhs.underlyingError.localizedDescription == rhs.underlyingError.localizedDescription
    }
}
