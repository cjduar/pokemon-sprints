//
//  FavoritesManager.swift
//  Pokemon
//
//  Created by Christopher Duarte on 5/18/26.
//

import Foundation

final class FavoritesManager: ObservableObject {
    @Published private var favoriteNames: Set<String> = []

    func isFavorite(_ pokemonName: String) -> Bool {
        favoriteNames.contains(normalizedName(for: pokemonName))
    }

    func toggleFavorite(for pokemonName: String) {
        let normalizedName = normalizedName(for: pokemonName)

        if favoriteNames.contains(normalizedName) {
            favoriteNames.remove(normalizedName)
        } else {
            favoriteNames.insert(normalizedName)
        }
    }

    private func normalizedName(for pokemonName: String) -> String {
        pokemonName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
