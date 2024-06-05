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
                            Text("Courses Information")
                                .font(.headline)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Courses Enrolled")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("\(user.enrolledCourseNumber)")
                                    
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Courses Teaching")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("\(user.teachingCourseNumber)")
                                }
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
                                        ClassCardView(baseClass: baseClass)
                                    }
                                }
                            }
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: .constant(DatabaseUser(userId: "1", userName: "John Doe", isTeacher: true, university: "Harvard", tags: ["Math", "Science"], availability: "Monday - Friday")))
    }
}
