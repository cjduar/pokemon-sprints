import Foundation

class FavoritesManager: ObservableObject {
    @Published private(set) var favoritePokemon: Set<String> = []
    private let saveKey = "FavoritePokemon"
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        if let data = UserDefaults.standard.array(forKey: saveKey) as? [String] {
            favoritePokemon = Set(data)
        }
    }
    
    func toggleFavorite(for pokemonName: String) {
        if favoritePokemon.contains(pokemonName) {
            favoritePokemon.remove(pokemonName)
        } else {
            favoritePokemon.insert(pokemonName)
        }
        saveFavorites()
    }
    
    func isFavorite(_ pokemonName: String) -> Bool {
        favoritePokemon.contains(pokemonName)
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoritePokemon), forKey: saveKey)
    }
} 