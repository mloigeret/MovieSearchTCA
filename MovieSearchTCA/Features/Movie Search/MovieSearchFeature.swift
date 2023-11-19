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
        
        var movieDetail: MovieDetailFeature.State?
    }
    
    enum Action {
        case searchQueryChanged(String)
        case debouncedSearchQueryChanged
        case moviesLoaded(Result<[Movie], APIError>)
        case movieTapped(Movie)
        case movieDetail(MovieDetailFeature.Action)
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
            return .none
            
        case .debouncedSearchQueryChanged:
            guard !state.searchQuery.isEmpty else { return .none }
            state.isLoading = true
            return Effect.run { [query = state.searchQuery] send in
                let result = await tmdbService.searchMovies(query: query)
                await send(.moviesLoaded(result))
            }
            .cancellable(id: CancelID.search)
            
        case let .moviesLoaded(.success(movies)):
            state.isLoading = false
            state.movies = movies
            return .none
            
        case let .moviesLoaded(.failure(error)):
            state.isLoading = false
            state.error = error
            return .none
            
        case let .movieTapped(movie):
            state.movieDetail = MovieDetailFeature.State(movie: movie)
            return .none
            
        case .movieDetail(.dismiss):
            state.movieDetail = nil
            return .none
        }
    }
}

fileprivate enum CancelID: Hashable {
    case search
}
