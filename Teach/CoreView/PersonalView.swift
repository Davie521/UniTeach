import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import Combine

final class PersonalViewModel: ObservableObject {
    @Published var user: DatabaseUser
    @Published var classes: [BaseClass] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var classesTeaching: [LiveClass] = []
    @Published var classesLearning: [LiveClass] = []
    @Published var confirmedClassesLearning: [LiveClass] = []
    
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
            await fetchTeachingClasses(for: fetchedUser.id)
            await fetchLearningClasses(for: fetchedUser.id)
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
    
    func fetchTeachingClasses(for userId: String) async {
        do {
            let fetchedClasses = try await LiveClassManager.shared.getClassTeaching(userId: userId)
            DispatchQueue.main.async {
                let currentDate = Date()
                self.classesTeaching = fetchedClasses.filter { $0.date > currentDate }.sorted(by: { $0.date > $1.date })
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load teaching classes: \(error.localizedDescription)"
            }
        }
    }
    
    func fetchLearningClasses(for userId: String) async {
        do {
            let fetchedClasses = try await LiveClassManager.shared.getClassLearning(userId: userId)
            DispatchQueue.main.async {
                self.classesLearning = fetchedClasses.filter { !$0.confirmed }.sorted(by: { $0.date > $1.date })
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load learning classes: \(error.localizedDescription)"
            }
        }
    }
    
    func confirmLearningClass(_ liveClass: LiveClass) async {
        do {
            try await LiveClassManager.shared.confirmLiveClass(classId: liveClass.id)
            DispatchQueue.main.async {
                self.classesLearning.removeAll { $0.id == liveClass.id }
                self.confirmedClassesLearning.append(liveClass)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to confirm class: \(error.localizedDescription)"
            }
        }
    }
}

struct PersonalView: View {
    @StateObject var viewModel = PersonalViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                    
                    Text(viewModel.user.userName)
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
                                    Text(viewModel.user.university)
                                }
                                Spacer()
                            }
                        }
                        Group {
                            Text("Tags and Specializations")
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.user.tags, id: \.self) { tag in
                                        TagView(tag: tag)
                                    }
                                }
                            }
                        }
                        
                        Group {
                            Text("Teaching Classes")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                if viewModel.classesTeaching.isEmpty {
                                    Text("No classes available.")
                                        .foregroundColor(.gray)
                                } else {
                                    ForEach(viewModel.classesTeaching) { liveClass in
                                        LiveClassCardView(liveClass: liveClass)
                                    }
                                }
                            }
                        }
                        
                        Group {
                            Text("Learning Classes")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                if viewModel.classesLearning.isEmpty {
                                    Text("No classes available.")
                                        .foregroundColor(.gray)
                                } else {
                                    ForEach(viewModel.classesLearning) { liveClass in
                                        if(!liveClass.confirmed) {
                                            LiveClassCardView(liveClass: liveClass)
                                        }
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



struct LiveClassCardView: View {
    var liveClass: LiveClass
    @State private var showReview = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(liveClass.name)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("Duration: \(liveClass.duration) min")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(liveClass.note)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Spacer()
                Text("Date: \(liveClass.date, formatter: DateFormatter.shortDate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if classEnd(LiveClass: liveClass) {
                Button("Confirm") {
                    showReview = true
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .sheet(isPresented: $showReview) {
                    ReviewView(liveClass: liveClass)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground)) // Use system background color
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5) // Apply subtle shadow
    }
    
    func classEnd(LiveClass: LiveClass) -> Bool {
        let currentDate = Date()
        return LiveClass.date <= currentDate
    }
}

extension DateFormatter {
    static var shortDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
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
