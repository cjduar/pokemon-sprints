////
////  ContentView.swift
////  Landmarks
////
////  Created by Christopher Duarte on 5/21/23.
////

import SwiftUI

struct ListView: View {
    @ObservedObject var listModel = PokemonViewModel()

    var body: some View {
        NavigationView {
            List(listModel.pokemons, id: \.name) { pokemon in
                NavigationLink(destination:PokemonView(pokemonName: pokemon.name)){ Text(pokemon.name)}
            }
            .navigationTitle("Pokémons")
            .onAppear {
                listModel.fetchPokemons()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
