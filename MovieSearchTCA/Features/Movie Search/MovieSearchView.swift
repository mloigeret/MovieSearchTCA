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

                if viewStore.searchQuery.isEmpty {
                    
                    VStack {
                        Image(systemName: "arrow.up")
                        Text("Enter a keyword to search a movie")
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if viewStore.isLoading {
                    
                    VStack {
                        ProgressView()
                        Text("Loading")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if !viewStore.movies.isEmpty {
                    
                    List(viewStore.movies, id: \.id) { movie in
                        VStack(alignment: .leading) {
                            Text(movie.title).bold()
                            Text(movie.releaseDate).italic()
                        }
                    }

                } else if viewStore.error != nil {
                    
                    VStack {
                        Text("Error: \(viewStore.error!.localizedDescription)")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    
                    VStack {
                        Text("No results!")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                MovieSearchFeature()
            }
        )
    )

}
