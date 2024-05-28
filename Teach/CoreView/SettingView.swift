//
//  SettingsView.swift
//  Teach
//
//  Created by Davie on 26/05/2024.
//

import SwiftUI

@MainActor
final class SettingsModel: ObservableObject {
    
    func logOut() throws {
        try AuthenticationManager.shared.logOut()
    }
}



struct SettingView: View {

    @Binding var showLogInView: Bool
    @StateObject private var model = SettingsModel()
    private var notShowLogInView: Binding<Bool> {
            Binding(
                get: { !self.showLogInView },
                set: { self.showLogInView = !$0 }
            )
        }
    var body: some View {
        NavigationStack {
            List {
                Button("Log Out") {
                    Task {
                        do {
                            try model.logOut()
                            showLogInView = true
                        } catch {
                            print(error)
                        }
                    }
                    
                }
            }
            .navigationBarTitle("Settings")
        }
        
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(showLogInView: .constant(false))
    }
}
