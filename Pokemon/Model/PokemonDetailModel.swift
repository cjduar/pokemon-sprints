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

    return try await fetchDecodable(from: url)
}

func getEvolvedSprintPokemon(for pokemonName: String, currentLevel: Int) async throws -> SprintPokemon? {
    let pokemon = try await getPokemon(pokemonName: pokemonName)
    let species = try await fetchDecodable(SpeciesData.self, from: pokemon.species.url)
    let evolutionChain = try await fetchDecodable(EvolutionChainData.self, from: species.evolutionChain.url)

    guard let evolvedName = evolutionChain.chain.nextEvolutionName(after: pokemon.species.name) else {
        return nil
    }

    let evolvedPokemon = try await getPokemon(pokemonName: evolvedName)

    return SprintPokemon(
        name: evolvedPokemon.species.name,
        artworkURL: evolvedPokemon.officialArtworkURL,
        level: currentLevel
    )
}

func getEvolutionChainNames(for pokemonName: String) async throws -> [String] {
    let pokemon = try await getPokemon(pokemonName: pokemonName)
    let species = try await fetchDecodable(SpeciesData.self, from: pokemon.species.url)
    let evolutionChain = try await fetchDecodable(EvolutionChainData.self, from: species.evolutionChain.url)

    return evolutionChain.chain.evolutionNames
}

private func fetchDecodable<T: Decodable>(_ type: T.Type = T.self, from url: URL) async throws -> T {
    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw PKError.invalidResponse
    }

    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
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

    var officialArtworkURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
    }
}

struct SpeciesData: Codable {
    struct EvolutionChainReference: Codable {
        let url: URL
    }

    let evolutionChain: EvolutionChainReference
}

struct EvolutionChainData: Codable {
    struct ChainLink: Codable {
        struct Species: Codable {
            let name: String
            let url: URL
        }

        let species: Species
        let evolvesTo: [ChainLink]

        var evolutionNames: [String] {
            [species.name] + evolvesTo.flatMap(\.evolutionNames)
        }

        func nextEvolutionName(after pokemonName: String) -> String? {
            if species.name.lowercased() == pokemonName.lowercased() {
                return evolvesTo.first?.species.name
            }

            for evolution in evolvesTo {
                if let nextName = evolution.nextEvolutionName(after: pokemonName) {
                    return nextName
                }
            }

            return nil
        }
    }

    let chain: ChainLink
}

enum PKError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
