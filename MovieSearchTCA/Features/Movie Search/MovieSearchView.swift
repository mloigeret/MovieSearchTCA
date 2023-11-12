//
//  MovieSearchView.swift
//  MovieSearchTCA
//
//  Created by Manuel Loigeret on 2023-11-12.
//

import ComposableArchitecture
import SwiftUI

struct MovieSearchView: View {
    
    let store: StoreOf<MovieSearchFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                TextField(
                    "Search Movies",
                    text: viewStore.binding(
                        get: \.searchQuery,
                        send: MovieSearchFeature.Action.searchQueryChanged
                    )
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

                List(viewStore.movies, id: \.title) { movie in
                    Text(movie.title)
                }
            }
        }
    }
}


#Preview("MovieSearchView") {

    MovieSearchView(
        store: Store(
            initialState: MovieSearchFeature.State(),
            reducer: {
                MovieSearchFeature(
                    movieService: MockMovieService()
                )
            }
        )
    )

}
