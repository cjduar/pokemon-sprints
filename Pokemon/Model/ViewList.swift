//
//  PokemonList.swift
//  Pokemon
//
//  Created by Christopher Duarte on 1/25/24.
//

import Foundation
import Combine

class PokemonViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []
    @Published var isLoading = false
    
    private var currentPage = 0
    private let pageSize = 20
    private var canLoadMorePages = true
    
    func loadMorePokemonIfNeeded() {
        guard !isLoading && canLoadMorePages else { return }
        fetchPokemons()
    }
    
    func fetchPokemons() {
        guard !isLoading && canLoadMorePages else { return }
        
        isLoading = true
        
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?offset=\(currentPage * pageSize)&limit=\(pageSize)")!
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let data = data {
                    do {
                        let pokemonResponse = try JSONDecoder().decode(PokemonResponse.self, from: data)
                        self.pokemons.append(contentsOf: pokemonResponse.results)
                        self.currentPage += 1
                        self.canLoadMorePages = !pokemonResponse.results.isEmpty
                    } catch {
                        print("Error decoding data: \(error.localizedDescription)")
                    }
                }
            }
        }.resume()
    }
}

struct PokemonResponse: Codable {
    var results: [Pokemon]
}

struct Pokemon: Codable, Identifiable {
    let id: UUID
    var name: String
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case name, url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        id = UUID()
    }
}
