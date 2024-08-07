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

@MainActor
class RecommendationsViewModel: ObservableObject {
    @Published var recommendedUsers: [DatabaseUser] = []
    
    func fetchRecommendedUsers() async {
        do {
            recommendedUsers = try await UserManager.shared.getRecommandedUsers()
        } catch {
            print("Error fetching recommended users: \(error)")
        }
    }
}


struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        VStack {
            HeaderView(searchText: $viewModel.searchText, onSearch: {
                Task {
                    await viewModel.searchUsers()
                }
            }, onCancel: {
                viewModel.cancelSearch()
            })
            
            NavigationView {
                ScrollView {
                    contentBody
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
            }
        }
    }
    
    @ViewBuilder
    var contentBody: some View {
        if viewModel.searchText.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                StudentRecommendationsView(searchText: viewModel.searchText)
                CommunityView(searchText: viewModel.searchText)
            }
            .padding(.horizontal)
        } else {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.users, id: \.id) { user in
                    NavigationLink(destination: ProfileView(user: .constant(user))) {
                        StudentCardView(student: user)
                    }
                }
            }
            .padding(.horizontal)
        }
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
            .padding(.horizontal)
            .padding(.top, 8) // Adjust padding specifically for your layout needs
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
            Button(searchText.isEmpty ? "Search" : "Cancel") {
                if searchText.isEmpty {
                    onSearch()
                } else {
                    onCancel()
                }
            }
            .transition(.scale)
        }
        .padding(.horizontal)  // Control padding to affect overall size and placement
    }
}


struct AvatarView: View {
    var body: some View {
        Image(systemName: "person.crop.circle")
            .resizable()
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            .shadow(radius: 2)
            .foregroundColor(.black)
    }
}

struct StudentRecommendationsView: View {
    @StateObject private var model = RecommendationsViewModel()
    var searchText: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("My Recommendations")
                .font(.title2)
                .bold()
            LazyVStack(spacing: 16) {
                ForEach(model.recommendedUsers) { user in
                    NavigationLink(destination: ProfileView(user: .constant(user))) {
                        StudentCardView(student: user)
                    }
                }
            }
        }
        .padding(.bottom, 8)
        .onAppear {
            Task {
                await model.fetchRecommendedUsers()
            }
        }
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
        HStack(alignment: .top, spacing: 16) {
            AvatarView()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(student.userName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(student.university)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !student.tags.isEmpty {
                    HStack {
                        ForEach(student.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
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
