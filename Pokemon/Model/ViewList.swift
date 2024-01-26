//
//  PokemonList.swift
//  Pokemon
//
//  Created by Christopher Duarte on 1/25/24.
//

import Foundation

struct PokemonResponse: Codable {
    var results: [Pokemon]
}

class PokemonViewModel: ObservableObject {
    @Published var pokemons = [Pokemon]()
    @Published var isLoading = false

    func fetchPokemons() {
        isLoading = true
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                do {
                    let pokemonResponse = try JSONDecoder().decode(PokemonResponse.self, from: data)
                    self.pokemons = pokemonResponse.results
                } catch {
                    print("Error decoding data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

}

struct Pokemon: Codable {
    //var id: UUID = UUID()
    var name: String
    var url: String
}
