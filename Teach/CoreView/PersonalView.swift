import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import Combine

final class PersonalViewModel: ObservableObject {
    @Published var user: DatabaseUser
    @Published var classes: [BaseClass] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    init() {
        user = DatabaseUser(userId: "", userName: "", isTeacher: false, university: "", tags: [], availability: "")
    }
    
    func loadCurrentUser() async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            let fetchedUser = try await UserManager.shared.getUser(userId: authDataResult.uid)
            DispatchQueue.main.async {
                self.user = fetchedUser
                self.isLoading = false
            }
            await fetchClasses(for: fetchedUser.id)
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load user data: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func fetchClasses(for userId: String) async {
        do {
            let fetchedClasses = try await ClassManager.shared.getBaseClassOfUser(userId: userId)
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

struct PersonalView: View {
    @StateObject var viewModel = PersonalViewModel()
    
    var body: some View {
        let user = viewModel.user
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
        .refreshable {
            await viewModel.loadCurrentUser()
        }
        .task {
            await viewModel.loadCurrentUser()
        }
    }
}

struct ClassCardView: View {
    var baseClass: BaseClass
    
    var body: some View {
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
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct TagView: View {
    var tag: String
    
    var body: some View {
        Text(tag)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
    }
}

struct PersonalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PersonalView()
        }
    }
}
