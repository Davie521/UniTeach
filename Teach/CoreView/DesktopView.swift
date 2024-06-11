//
//  DesktopView.swift
//  Teach
//
//  Created by Davie on 28/05/2024.
//

import SwiftUI

import SwiftUI

struct DesktopView: View {
    @Binding var showLogInView: Bool
    @StateObject private var settingsModel = SettingsModel() // Instantiate SettingsModel

    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            NavigationView {
                PersonalView()
                    .toolbar {
                        // Add Calendar Icon in the Navigation Bar
                        ToolbarItem(placement: .navigationBarLeading) {
                            NavigationLink(destination: ScheduleView()) {
                                Image(systemName: "calendar").font(.headline).foregroundColor(.black)
                            }
                        }
                        // Existing Settings Icon
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: SettingView(showLogInView: $showLogInView, settingsModel: settingsModel)) {
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
