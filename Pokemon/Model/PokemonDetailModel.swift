//
//  ModelData.swift
//  Landmarks
//
//  Created by Christopher Duarte on 6/28/23.
//

import Foundation

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

struct PokemonData: Codable {
    struct Species: Codable {
        let name: String
        let url: URL
    }

    struct Sprites: Codable {
        let frontDefault: URL?
        let backDefault: URL?
        let frontShiny: URL?
        let backShiny: URL?
    }

    struct PokemonType: Codable, Identifiable {
        struct TypeInfo: Codable {
            let name: String
            let url: URL
        }

        let slot: Int
        let type: TypeInfo

        var id: Int { slot }
    }

    struct Stat: Codable, Identifiable {
        struct StatInfo: Codable {
            let name: String
            let url: URL
        }

        let baseStat: Int
        let stat: StatInfo

        var id: String { stat.name }
    }

    let id: Int
    let height: Int
    let weight: Int
    let baseExperience: Int?
    let sprites: Sprites
    let species: Species
    let types: [PokemonType]
    let stats: [Stat]
}

enum PKError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
