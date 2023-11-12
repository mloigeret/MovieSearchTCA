//
//  MovieSearchFeature.swift
//  MovieSearchTCA
//
//  Created by Manuel Loigeret on 2023-11-10.
//

import ComposableArchitecture
import Foundation

struct MovieSearchFeature: Reducer {
    
    // MARK: Definitions
    
    struct State: Equatable {
        var searchQuery: String = ""
        var movies: [Movie] = []
        var isLoading: Bool = false
        var error: APIError?
    }
    
    enum Action {
        case searchQueryChanged(String)
        case moviesLoaded(Result<[Movie], APIError>)
    }
    
    // MARK: Properties
    
    let tmdbService: TMDBServiceProtocol = TMDBService.make()

    // MARK: Reduce
    
    func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        switch action {
        case let .searchQueryChanged(query):
            state.searchQuery = query
            if !query.isEmpty {
                state.isLoading = true
                return .run { send in
                    let result = await tmdbService.searchMovies(query: query)
                    await send(.moviesLoaded(result))
                }
            } else {
                state.isLoading = false
                state.movies = []
                return .none
            }
            
        case let .moviesLoaded(.success(movies)):
            state.isLoading = false
            state.movies = movies
            return .none

        case let .moviesLoaded(.failure(error)):
            state.isLoading = false
            state.error = error
            return .none
        }
    }
}
