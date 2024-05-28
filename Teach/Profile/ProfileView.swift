//
//  ProfileView.swift
//  Teach
//
//  Created by Davie on 27/05/2024.
//

import SwiftUI

final class ProfileViewModel: ObservableObject {
    
    @Published var user: DatabaseUser?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadCurrentUser() async {
        isLoading = true
        errorMessage = nil
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            user = try await UserManager.shared.getUser(userId: authDataResult.uid)
            isLoading = false
        } catch {
            errorMessage = "Failed to load user data: \(error.localizedDescription)"
            isLoading = false
        }
    }
    func toggleTeacherStatus() {
        guard let user else { return }
        let currentValue = !user.isTeacher
        Task {
            try await UserManager.shared.updateUserTeacherStatus(userId: user.userId, isTeacher: currentValue)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
}

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showLogInView: Bool

    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserId: \(user.userId)")
                Text("Email: \(user.email)")
                if let photoUrl = user.photoUrl {
                    Text("Photo URL: \(photoUrl)")
                }
                Text("Date Created: \(user.dateCreated, style: .date)")
                Text("Teacher: \(user.isTeacher ? "Yes" : "No")")
            } else if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
        }
        .task {
            await viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingView(showLogInView: $showLogInView)) {
                    Image(systemName: "gear").font(.headline)
                }
            }
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView(showLogInView: .constant(false))
        }
    }
}
