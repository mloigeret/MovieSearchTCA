//
//  MovieSearchView.swift
//  MovieSearchTCA
//
//  Created by Manuel Loigeret on 2023-11-12.
//

import ComposableArchitecture
import SwiftUI

// MARK: - MovieSearchView

struct MovieSearchView: View {
    let store: StoreOf<MovieSearchFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                MovieSearchContentView(store: store)
                    .navigationTitle("Movies")
            }
            .task(id: viewStore.searchQuery) {
                await handleDebouncedSearch(viewStore: viewStore)
            }
        }
    }
    
    private func handleDebouncedSearch(viewStore: ViewStore<MovieSearchFeature.State, MovieSearchFeature.Action>) async {
        do {
            try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    viewStore.send(.debouncedSearchQueryChanged)
                    continuation.resume()
                }
            }
        } catch {}
    }
}

// MARK: - MovieSearchContentView

struct MovieSearchContentView: View {
    let store: StoreOf<MovieSearchFeature>
    
    var body: some View {
        VStack {
            MovieSearchBar(store: store)
            MovieSearchResults(store: store)
        }
    }
}

// MARK: - MovieSearchResults

struct MovieSearchResults: View {
    
    let store: StoreOf<MovieSearchFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            if viewStore.searchQuery.isEmpty {
                PlaceholderView()
            } else if viewStore.isLoading {
                LoadingView()
            } else if !viewStore.movies.isEmpty {
                MovieListView(movies: viewStore.movies, store: store)
            } else if let error = viewStore.error {
                ErrorView(error: error)
            } else {
                NoResultsView()
            }
        }
    }
}

// MARK: - PlaceholderView

struct PlaceholderView: View {
    var body: some View {
        VStack {
            Image(systemName: "arrow.up")
            Text("Enter a keyword to search a movie")
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - LoadingView

struct LoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - ErrorView

struct ErrorView: View {
    
    let error: Error
    
    var body: some View {
        Text("Error: \(error.localizedDescription)")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - NoResultsView

struct NoResultsView: View {
    
    var body: some View {
        Text("No results!")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - MovieSearchBar

struct MovieSearchBar: View {
    
    let store: StoreOf<MovieSearchFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            TextField(
                "Search Movies",
                text: viewStore.binding(
                    get: \.searchQuery,
                    send: MovieSearchFeature.Action.searchQueryChanged
                )
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
        }
    }
}

// MARK: - MovieListView

struct MovieListView: View {
    let movies: [Movie]
    let store: StoreOf<MovieSearchFeature>
    
    var body: some View {
        List(movies, id: \.id) { movie in
            MovieRow(movie: movie, store: store)
        }
    }
}

// MARK: - MovieRow

struct MovieRow: View {
    let movie: Movie
    let store: StoreOf<MovieSearchFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationLink(
                destination: IfLetStore(
                    self.store.scope(
                        state: \.movieDetail,
                        action: MovieSearchFeature.Action.movieDetail
                    ),
                    then: MovieDetailView.init(store:)
                ),
                isActive: viewStore.binding(
                    get: { $0.movieDetail?.movie.id == movie.id },
                    send: MovieSearchFeature.Action.movieDetail(.dismiss)
                )
            ) {
                MovieCell(movie: movie)
            }
            .onTapGesture {
                viewStore.send(.movieTapped(movie))
            }
        }
    }
}

// MARK: - MovieCell

struct MovieCell: View {
    let movie: Movie
    
    var body: some View {
        HStack {
            Group {
                if let posterURL = movie.posterURL {
                    AsyncImage(url: posterURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            Image(systemName: "questionmark")
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "questionmark")
                }
            }
            .frame(width: 50, height: 100)
            
            VStack(alignment: .leading) {
                Text(movie.title).bold()
                Text(movie.releaseDate).italic()
            }
        }
    }
}

// MARK: - Preview

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
