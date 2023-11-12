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
    }
    
    enum Action {
        case searchQueryChanged(String)
        case moviesLoaded(Result<[Movie], Error>)
    }
    
    // MARK: Properties
    
    let tmdbService: TMDBServiceProtocol = TMDBService.make()
    
    // MARK: Reduce
    
    func reduce(
        into state: inout State,
        action: Action
    ) -> ComposableArchitecture.Effect<Action> {
        switch action {
            
        case let .searchQueryChanged(searchQuery):
            state.searchQuery = searchQuery
            return .run { send in
                let result = await tmdbService.searchMovies(query: searchQuery)
                await send(.moviesLoaded(result))
            }
  
        case let .moviesLoaded(.success(movies)):
            state.movies = movies
            return .none
            
        case let .moviesLoaded(.failure(error)):
            // TODO: handle error case
            print("Oh no! \(error.localizedDescription)")
            return .none
        }
    }
}

