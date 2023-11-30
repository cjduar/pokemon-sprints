//
//  ModelData.swift
//  Landmarks
//
//  Created by Christopher Duarte on 6/28/23.
//

import Foundation


func getPokemon() async throws -> Pokemon {
    let endpoint = "https://pokeapi.co/api/v2/pokemon/1"
    
    guard let url = URL(string: endpoint) else{
        throw PKError.invalidURL
    }
    let(data, response) = try await URLSession.shared.data(from:url)
    
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        throw PKError.invalidResponse
    }
    
    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Pokemon.self, from: <#T##Data#>)
    } catch {
        throw PKError.invalidData
    }
}

struct Pokemon:Codable {
    let name: String
}

enum PKError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
