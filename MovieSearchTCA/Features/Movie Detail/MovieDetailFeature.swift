//
//  MovieDetailFeature.swift
//  MovieSearchTCA
//
//  Created by Manuel Loigeret on 2023-11-19.
//

import ComposableArchitecture
import Foundation

struct MovieDetailFeature: Reducer {
    struct State: Equatable {
        var movie: Movie
    }
    
    enum Action: Equatable {
        case dismiss
    }
    
    func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        switch action {
        case .dismiss:
            return .none
        }
    }
}
