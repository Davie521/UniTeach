//
//  ContentView.swift
//  Teach
//
//  Created by Davie on 26/05/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            NavigationStack {
                RootView()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
