//
//  ContentView.swift
//  Landmarks
//
//  Created by Christopher Duarte on 5/21/23.
//

import SwiftUI

struct ListView: View {
    var body: some View {
        NavigationView{
            List(view)
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
