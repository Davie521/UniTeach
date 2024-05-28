//
//  AuthenView.swift
//  Teach
//
//  Created by Davie on 26/05/2024.
//

import SwiftUI

struct AuthenView: View {
    var body: some View {
            NavigationView {
                VStack {
                    if showSignUp {
                        SignUpView(authViewModel: authViewModel)
                    } else {
                        SignInView(authViewModel: authViewModel)
                    }
                    // Toggle view button or similar
                    Button("Switch to \(showSignUp ? "Sign In" : "Sign Up")") {
                        showSignUp.toggle()
                    }
                }
            }
        }
}

#Preview {
    AuthenView()
}
