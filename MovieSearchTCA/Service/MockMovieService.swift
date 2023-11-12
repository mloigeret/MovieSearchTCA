//
//  MockMovieService.swift
//  MovieSearchTCA
//
//  Created by Manuel Loigeret on 2023-11-10.
//

import Foundation

struct MockMovieService {
    func searchMovies(query: String) async -> Result<[Movie], Error> {
        guard !query.isEmpty else {
            return .failure(NSError(domain: "EmptyQuery", code: 0))
        }

        let mockMovies = [
            Movie(title: "The Shawshank Redemption"),
            Movie(title: "The Godfather"),
            Movie(title: "The Dark Knight"),
            Movie(title: "12 Angry Men"),
            Movie(title: "Schindler's List")
        ]

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        return .success(mockMovies)
    }
}
