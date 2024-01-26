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
        NavigationView(
            List(listModel.pokemons){ pokemons in
                Text(pokemon.name)
            }
                        .navigationTitle("Pokémons")
                        .onAppear {
                            viewModel.fetchPokemons()
                        }
                    }
                }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ListView()
        }
    }

