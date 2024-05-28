//
//  SignUpView.swift
//  Teach
//
//  Created by Davie on 26/05/2024.
//

import SwiftUI

final class SignUpEmailModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage: String? = nil
    
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Email and password are required.")
            errorMessage = "Email and password are required."
            return
        }
        // add a password match check
        guard password == confirmPassword else {
            print("Passwords do not match.")
            errorMessage = "Passwords do not match."
            return
        }
        // add minimum passward length check
        guard password.count >= 6 else {
            print("Password must be at least 6 characters.")
            errorMessage = "Password must be at least 6 characters."
            return
        }
        guard validEmail(email: email) else {
            print("Invalid email.")
            errorMessage = "Invalid email."
            return
        }
        
        // add a valid email check
        func validEmail(email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
        }
        
        try await AuthenticationManager.shared.createUser(email: email, password: password)
        // print email
        print("Email: \(email) signed up successfully.")
        
    }
}

struct SignUpView: View {
    @StateObject private var model = SignUpEmailModel()
    @State private var navigateToLogin: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                
                // Welcome text
                Text("Welcome to UniTeach!")
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
                
                // Confirm password input field
                SecureField("Confirm your password", text: $model.confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                
                // Register button
                Button {
                    Task {
                        do {
                            try await model.signUp()
                            navigateToLogin = true
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black) // Use your brand color here
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .padding(.top, 20)
                .shadow(radius: 2)
                .alert("Error", isPresented: .init(get: { model.errorMessage != nil }, set: { _ in model.errorMessage = nil })) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(model.errorMessage ?? "")
                }
                .alert("Success", isPresented: $navigateToLogin) {
                    Button("OK", role: .cancel) {
                        dismiss()
                    }
                } message: {
                    Text("Sign-up successful. Please log in.")
                }
                
                Spacer()
                Spacer()
                
                // Navigation to login page
                HStack {
                    Text("Already have an account?")
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Login")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
