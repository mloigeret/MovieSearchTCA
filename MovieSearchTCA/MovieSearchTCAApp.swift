//
//  MovieSearchTCAApp.swift
//  MovieSearchTCA
//
//  Created by Manuel Loigeret on 2023-11-10.
//

import ComposableArchitecture
import SwiftUI

@main
struct MoviesApp: App {
    
    let store = Store(
        initialState: MovieSearchFeature.State(),
        reducer: {
            MovieSearchFeature(movieService: MockMovieService())
        }
    )

    var body: some Scene {
        WindowGroup {
            MovieSearchView(store: store)
        }
    }
}
