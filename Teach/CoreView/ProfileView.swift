//
//  ProfileView.swift
//  Teach
//
//  Created by Davie on 04/06/2024.
//

// Create a profile view for other users to view

import SwiftUI



final class ProfileViewModel: ObservableObject {
    @Published var user: DatabaseUser
    @Published var classes: [BaseClass] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init (user: DatabaseUser) {
        self.user = user
    }
    
    func loadUserClasses() async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let fetchedClasses = try await ClassManager.shared.getBaseClassOfUser(userId: user.id)
            DispatchQueue.main.async {
                self.classes = fetchedClasses
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load classes: \(error.localizedDescription)"
            }
        }
    }
}

struct ProfileView: View {
    @Binding var user: DatabaseUser
    @StateObject var viewModel: ProfileViewModel

    init(user: Binding<DatabaseUser>) {
        self._user = user
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(user: user.wrappedValue))
    }

    var body: some View {
        
        Text("Hello, \(user.userName)!")
        
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: .constant(DatabaseUser(userId: "123", userName: "Davie", isTeacher: true, university: "UoM", tags: ["Maths", "Science"], availability: "Weekends")))
    }
}
