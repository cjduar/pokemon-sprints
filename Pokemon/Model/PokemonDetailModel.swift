//
//  ModelData.swift
//  Landmarks
//
//  Created by Christopher Duarte on 6/28/23.
//

import Foundation
import SwiftUI

func getPokemon(pokemonName: String) async throws -> PokemonData {
    guard let encodedPokemonName = pokemonName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
          let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(encodedPokemonName)") else {
        throw PKError.invalidURL
    }

    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw PKError.invalidResponse
    }

    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(PokemonData.self, from: data)
    } catch {
        throw PKError.invalidData
    }
}
    
    struct PokemonData:Codable {
        struct Species: Codable {
            let name: String
            let url: URL
        }
        struct Sprites: Codable{
            let backDefault: URL?
            let frontShiny: String
        }
        let sprites: Sprites
        let species: Species
    }
    
    enum PKError: Error {
        case invalidURL
        case invalidResponse
        case invalidData
    }

