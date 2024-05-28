//
//  RootView.swift
//  Teach
//
//  Created by Davie on 26/05/2024.
//

import SwiftUI

struct RootView: View {
    
    @State private var showLogInView: Bool = true
    
    
    
    var body: some View {
        
        ZStack {
            if !showLogInView {
                NavigationStack {
                    DesktopView(showLogInView: $showLogInView)
                }
            }
        }
        .onAppear() {
            let authuser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showLogInView = authuser == nil
            
            
        }
        .fullScreenCover(isPresented: $showLogInView) {
            NavigationStack {
                LogInView(showLogInView: $showLogInView)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RootView()
        }
    }
}
