//
//  ModelData.swift
//  Landmarks
//
//  Created by Christopher Duarte on 6/28/23.
//

import Foundation
import SwiftUI


struct ContentView: View {
    @State private var pkmon: PokemonData?
    
    var body: some View {
        VStack(spacing: 20){
            AsyncImage(url: URL(string: pkmon?.sprites.fontShiny ?? "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png")) {image in
                image} placeholder:{
                    Circle()
                        .foregroundColor(.secondary)
                        .frame(width: 120, height: 120)
                }
            Text(pkmon?.species.name ?? "No Name")
                .bold()
                .font(.title3)
        }
        .task {
            do {
                pkmon = try await getPokemon()
            }
            catch {
            }}
        
}
struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
}
    
    
    func getPokemon() async throws -> PokemonData {
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
            let fontShiny: String
        }
        let sprites: Sprites
        let species: Species
    }
    
    enum PKError: Error {
        case invalidURL
        case invalidResponse
        case invalidData
    }
}
