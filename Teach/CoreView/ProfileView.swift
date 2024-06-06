//
//  ProfileView.swift
//  Teach
//
//  Created by Davie on 04/06/2024.
//

// Create a profile view for other users to view

import SwiftUI
import FirebaseFirestore



final class ProfileViewModel: ObservableObject {
    @Published var classes: [BaseClass] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    
    private var userId: String
    private var db = Firestore.firestore()
    
    init(userId: String) {
        self.userId = userId
    }
    
    func loadUserProfile(_ userId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedClasses = try await ClassManager.shared.getBaseClassOfUser(userId: userId)
            DispatchQueue.main.async {
                self.classes = fetchedClasses
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load profile data: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
}


struct ProfileView: View {
    @Binding var user: DatabaseUser
    @StateObject var viewModel: ProfileViewModel
    
    init(user: Binding<DatabaseUser>) {
        self._user = user
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userId: user.wrappedValue.id))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                    
                    Text(user.userName)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.top, 10)
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            Text("Educational Details")
                                .font(.headline)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Institution")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(user.university)
                                }
                                Spacer()
                            }
                        }
                        Group {
                            Text("Tags and Specializations")
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(user.tags, id: \.self) { tag in
                                        TagView(tag: tag)
                                    }
                                }
                            }
                        }
                        
                        Group {
                            Text("Classes")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                if viewModel.classes.isEmpty {
                                    Text("No classes available.")
                                        .foregroundColor(.gray)
                                } else {
                                    ForEach(viewModel.classes) { baseClass in
                                        ProfileClassCardView(baseClass: baseClass)
                                    }
                                }
                            }
                        }
                        
                        Group {
                            
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            Task {
                await viewModel.loadUserProfile(user.id)
            }
        }
    }
}

struct ProfileClassCardView: View {
    var baseClass: BaseClass
    
    var body: some View {
        NavigationLink(destination: ClassDetailView(baseClass: baseClass)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(baseClass.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Text("Price: ¥\(baseClass.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(baseClass.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Spacer()
                    RatingView(rating: baseClass.rating)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct RatingView: View {
    var rating: Double
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(rating) ? "star.fill" : "star")
                    .foregroundColor(index < Int(rating) ? Color.yellow : Color.gray)
            }
        }
        .font(.caption)
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: .constant(DatabaseUser(userId: "1", userName: "John Doe", isTeacher: true, university: "Harvard", tags: ["Math", "Science"], availability: "Monday - Friday")))
    }
}
