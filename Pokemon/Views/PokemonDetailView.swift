////
////  PokemonDetailView.swift
////  Pokemon
////
////  Created by Christopher Duarte on 1/28/24.
import SwiftUI

struct PokemonView: View {
    @State private var pkmon: PokemonData?
    var pokemonName: String

    var body: some View {
        VStack(spacing: 20){
            AsyncImage(url: URL(string: pkmon?.sprites.frontShiny ?? "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png")) { image in
                image.resizable()
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
                    .frame(width: 120, height: 120)
            }
            .frame(width: 120, height: 120)
            
            Text(pkmon?.species.name ?? "No Name")
                .bold()
                .font(.title3)
        }
        .task {
            do {
                pkmon = try await getPokemon(pokemonName: pokemonName)
            } catch {
                print("Error fetching Pokémon data: \(error)")
                // Handle the error appropriately
            }
        }
    }
}

struct PokemonView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonView(pokemonName: "pikachu") // Example Pokémon name for preview
    }
}
