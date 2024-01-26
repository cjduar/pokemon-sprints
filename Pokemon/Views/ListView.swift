////
////  ContentView.swift
////  Landmarks
////
////  Created by Christopher Duarte on 5/21/23.
////

import SwiftUI

struct ListView: View {
    var body: some View {
        NavigationView(
            List(listModel.pokemons){ pokemons in
                Text(pokemon.name)
            }
//            content: {
//            NavigationLink(destination:
//                            List{Text("Destination");
//                Text("Destination")
//            })
//            { /*@START_MENU_TOKEN@*/Text("Navigate")/*@END_MENU_TOKEN@*/ }
//        })
        
        
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ListView()
        }
    }

