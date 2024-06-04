import SwiftUI
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var users: [DatabaseUser] = []
    @Published var searchText: String = ""
    
    private var userManager = UserManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                if searchText.isEmpty {
                    self?.users = []
                } else {
                    Task {
                        await self?.searchUsers()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func searchUsers() async {
        guard !searchText.isEmpty else { return }
        do {
            users = try await userManager.searchUsersByName(name: searchText)
        } catch {
            print("Error searching users: \(error)")
            users = []
        }
    }
    
    func cancelSearch() {
        searchText = ""
        users = []
    }
}

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        VStack {
            // Using HeaderView which internally uses the updated SearchBar
            HeaderView(searchText: $viewModel.searchText, onSearch: {
                Task {
                    await viewModel.searchUsers()
                }
            }, onCancel: {
                viewModel.cancelSearch()
            })
            
            ScrollView {
                if viewModel.searchText.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        StudentRecommendationsView(searchText: viewModel.searchText)
                        CommunityView(searchText: viewModel.searchText)
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.users, id: \.id) { user in
                            StudentCardView(student: user)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}



struct HeaderView: View {
    @Binding var searchText: String
    var onSearch: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                SearchBar(searchText: $searchText, onSearch: onSearch, onCancel: onCancel)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 0.1)
        }
    }
}


struct SearchBar: View {
    @Binding var searchText: String
    var onSearch: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search for courses, teachers, and more...", text: $searchText)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .onSubmit(onSearch)
                .submitLabel(.search)
            
            // Conditional button that changes based on whether the user has begun typing
            Button(searchText.isEmpty ? "Search" : "Cancel") {
                if searchText.isEmpty {
                    onSearch()
                } else {
                    onCancel()
                }
            }
            .transition(.scale)
        }
        .padding(.horizontal)
    }
}





struct AvatarView: View {
    var body: some View {
        Image(systemName: "person.crop.circle")
            .resizable()
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            .shadow(radius: 2)
    }
}

struct StudentRecommendationsView: View {
    var searchText: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("My Recommendations")
                .font(.title2)
                .bold()
            LazyVStack(spacing: 16) {
                // Sample static data for demonstration
                ForEach(sampleUsers) { user in
                    StudentCardView(student: user)
                }
            }
        }
        .padding(.bottom, 8)
    }
}


struct CommunityView: View {
    var searchText: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Community")
                .font(.title2)
                .bold()
            LazyVStack(spacing: 16) {
                // Assuming communities is an array of Community objects
                ForEach(communities) { community in
                    CommunityCardView(community: community)
                }
            }
        }
        .padding(.bottom, 8)
    }
}

struct StudentCardView: View {
    let student: DatabaseUser
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AvatarView()
                VStack(alignment: .leading) {
                    Text(student.userName)
                        .font(.headline)
                    Text(student.university)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(student.tags, id: \.self) { tag in
                        Text(tag)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity) // Ensure the card takes the full width available
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 0.5)
    }
}



struct CommunityCardView: View {
    let community: Community
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(community.name)
                .font(.headline)
            Text(community.description)
                .font(.body)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity) // Ensure the card takes the full width available
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 0.5)
    }
}

struct CircleAvatarView: View {
    let activity: Activity
    
    var body: some View {
        VStack {
            AvatarView()
                .frame(width: 32, height: 32)
            Text(activity.userName)
                .font(.caption)
                .lineLimit(1)
        }
    }
}


struct Community: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let activities: [Activity]
}

struct Activity: Identifiable {
    let id = UUID()
    let userName: String
    let description: String
}

let sampleUsers = [
    DatabaseUser(userId: "1", userName: "Alice", isTeacher: false, university: "University of California, Berkeley",  tags: ["A* on math, A* on physics"], availability: "Weekends"),
    DatabaseUser(userId: "2", userName: "Bob", isTeacher: false, university: "University of California, Berkeley", tags: ["A* on math, A* on physics"], availability: "Weekends"),
    DatabaseUser(userId: "3", userName: "Charlie", isTeacher: false, university: "University of California, Berkeley", tags: ["A* on math, A* on physics"], availability: "Weekends"),
]

let communities = [
    Community(name: "Math Community", description: "Discuss math concepts, share solutions, and connect with other math enthusiasts.", activities: []),
    //    Community(name: "Physics Community", description: "Discuss physics concepts, share experiments, and connect with other physics enthusiasts.", activities: []),
    Community(name: "English Community", description: "Discuss literature, writing techniques, and connect with other English enthusiasts.", activities: []),
    // Add more communities as needed
]

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .preferredColorScheme(.light)
        //        SearchView()
        //            .preferredColorScheme(.dark)
    }
}
