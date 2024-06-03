//
//  SignInView.swift
//  Teach
//
//  Created by Davie on 26/05/2024.
//

import SwiftUI


final class LogInModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func login() async -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            print("Email and password are required")
            return false
        }
        
        do {
            let authDataResult = try await AuthenticationManager.shared.logInUser(email: email, password: password)
            // this is the database user
            let user = DatabaseUser(auth: authDataResult)
            print("Email: \(email) logged in successfully.")
            return true
        } catch {
            print(error)
            return false
        }
    }
}


struct LogInView: View {
    @Binding var showLogInView: Bool
    @StateObject private var model = LogInModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Spacer()
                
                // Welcome text
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 50)
                
                // Email input field
                TextField("Enter your email", text: $model.email)
                    .padding()
                    .background(Color(.systemGray6)) // Light gray background
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                
                // Password input field
                SecureField("Enter your password", text: $model.password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                
                // Login button
                Button {
                    Task {
                        let success = await model.login()
                        if success {
                            showLogInView = false
                        }
                    }
                } label: {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black) // Use your brand color here
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .padding(.top, 20)
                .shadow(radius: 2)
                
                Spacer()
                Spacer()
                
                // Navigation to sign-up page
                HStack {
                    Text("Don't have an account?")
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign Up")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LogInView(showLogInView: .constant(true))
        }
    }
}
