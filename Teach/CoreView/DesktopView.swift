//
//  DesktopView.swift
//  Teach
//
//  Created by Davie on 28/05/2024.
//

import SwiftUI

struct DesktopView: View {
    @Binding var showLogInView: Bool
    var body: some View {
            TabView {
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                
                NavigationView {
                    PersonalView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                NavigationLink(destination: SettingView(showLogInView: .constant(false))) {
                                    Image(systemName: "gearshape.fill").font(.headline).foregroundColor(.black)
                                }
                            }
                        }

                }
                    .tabItem {
                        Label("Me", systemImage: "person")
                    }
                    
            }
            
        }

}

struct DesktopView_Previews: PreviewProvider {
    static var previews: some View {
        DesktopView(showLogInView: .constant(false))
    }
}
