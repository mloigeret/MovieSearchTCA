//
//  TMDBService.swift
//  MovieSearchTCA
//
//  Created by Manuel Loigeret on 2023-11-12.
//

import Foundation

protocol TMDBServiceProtocol {
    func searchMovies(query: String) async -> Result<[Movie], Error>
    static func make() -> TMDBServiceProtocol
}

class TMDBService: TMDBServiceProtocol {
    private let apiService: APIServiceProtocol
    private let apiKey = APIKeyConstants.tmdbAPIKey
    private let baseUrl = "https://api.themoviedb.org/3"
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    static func make() -> TMDBServiceProtocol {
        return TMDBService(apiService: APIService.make())
    }

    func searchMovies(query: String) async -> Result<[Movie], Error> {
        guard let url = URL(string: "\(baseUrl)/search/movie?api_key=\(apiKey)&query=\(query)") else {
            return .failure(NSError(domain: "InvalidURL", code: 0))
        }

        let result: Result<TMDBSearchMoviesResponse, Error> = await apiService.request(url: url, expecting: TMDBSearchMoviesResponse.self)
        switch result {
        case .success(let response):
            return .success(response.results)
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - Definitions

struct TMDBSearchMoviesResponse: Decodable {
    let results: [Movie]
}
