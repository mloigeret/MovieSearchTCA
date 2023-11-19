//
//  MovieDetailView.swift
//  MovieSearchTCA
//
//  Created by Manuel Loigeret on 2023-11-19.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct MovieDetailView: View {
    let store: StoreOf<MovieDetailFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                AsyncImage(url: viewStore.movie.posterURL) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
                Text(viewStore.movie.title)
                    .font(.title)
                Text(viewStore.movie.releaseDate)
                    .italic()
            }
        }
    }
}
