////
////  ContentView.swift
////  Landmarks
////
////  Created by Christopher Duarte on 5/21/23.
////

import SwiftUI

struct ContentView: View {
    @StateObject private var favoritesManager = FavoritesManager()
    
    var body: some View {
        TabView {
            ListView()
                .tabItem {
                    Label("All Pokémon", systemImage: "list.bullet")
                }
                .environmentObject(favoritesManager)
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }
                .environmentObject(favoritesManager)
        }
    }
}

struct PokemonRowView: View {
    let pokemon: Pokemon
    
    var body: some View {
        Text(pokemon.name.capitalized)
    }
}

struct ListView: View {
    @StateObject private var viewModel = PokemonViewModel()
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.pokemons) { pokemon in
                    NavigationLink(destination: PokemonView(pokemonName: pokemon.name)) {
                        PokemonRowView(pokemon: pokemon)
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

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @StateObject private var viewModel = PokemonViewModel()
    
    var filteredPokemon: [Pokemon] {
        viewModel.pokemons.filter { favoritesManager.isFavorite($0.name) }
    }
    
    var body: some View {
        NavigationView {
            List {
                if filteredPokemon.isEmpty {
                    Text("No favorites yet")
                        .foregroundColor(.gray)
                } else {
                    ForEach(filteredPokemon) { pokemon in
                        NavigationLink(destination: PokemonView(pokemonName: pokemon.name)) {
                            PokemonRowView(pokemon: pokemon)
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
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
        ContentView()
    }
}
