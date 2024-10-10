////
////  ContentView.swift
////  Landmarks
////
////  Created by Christopher Duarte on 5/21/23.
////

import SwiftUI

struct ListView: View {
    @StateObject private var viewModel = PokemonViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.pokemons) { pokemon in
                    NavigationLink(destination: PokemonView(pokemonName: pokemon.name)) {
                        Text(pokemon.name)
                    }
                    .onAppear {
                        if pokemon.id == viewModel.pokemons.last?.id {
                            viewModel.loadMorePokemonIfNeeded()
                        }
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(idealWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Pokémons")
            .onAppear {
                if viewModel.pokemons.isEmpty {
                    viewModel.fetchPokemons()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
