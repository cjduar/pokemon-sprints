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
                    Label("All Pokemon", systemImage: "square.grid.2x2.fill")
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
    let isFavorite: Bool

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: pokemon.artworkURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
                    .controlSize(.small)
            }
            .frame(width: 72, height: 72)
            .padding(10)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(pokemon.name.capitalized)
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()

            Image(systemName: isFavorite ? "star.fill" : "chevron.right")
                .font(.headline)
                .foregroundStyle(isFavorite ? .yellow : .secondary)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

struct ListView: View {
    @StateObject private var viewModel = PokemonViewModel()
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        NavigationView {
            ZStack {
                PokemonTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.pokemons) { pokemon in
                            NavigationLink(destination: PokemonView(pokemonName: pokemon.name)) {
                                PokemonRowView(
                                    pokemon: pokemon,
                                    isFavorite: favoritesManager.isFavorite(pokemon.name)
                                )
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                if pokemon.id == viewModel.pokemons.last?.id {
                                    viewModel.loadMorePokemonIfNeeded()
                                }
                            }
                        }

                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.vertical, 24)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Pokemon")
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
            ZStack {
                PokemonTheme.background
                    .ignoresSafeArea()

                if filteredPokemon.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "star.circle")
                            .font(.system(size: 54))
                            .foregroundStyle(.yellow)

                        Text("No favorites yet")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("Mark Pokemon from a detail page and they will show up here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredPokemon) { pokemon in
                                NavigationLink(destination: PokemonView(pokemonName: pokemon.name)) {
                                    PokemonRowView(pokemon: pokemon, isFavorite: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
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

struct PokemonTheme {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.96, green: 0.98, blue: 1.0),
            Color(red: 0.98, green: 0.96, blue: 0.92)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accent = Color(red: 0.88, green: 0.18, blue: 0.24)
}

extension Pokemon {
    var pokemonNumber: Int? {
        URL(string: url)?
            .pathComponents
            .last(where: { Int($0) != nil })
            .flatMap(Int.init)
    }

    var formattedNumber: String {
        guard let pokemonNumber else { return "Unknown number" }
        return String(format: "#%03d", pokemonNumber)
    }

    var artworkURL: URL? {
        guard let pokemonNumber else { return nil }
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonNumber).png")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
