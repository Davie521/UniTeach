import SwiftUI

struct SearchView: View {
    @State private var searchText = ""

    var body: some View {
        VStack {
            HeaderView(searchText: $searchText)
            ScrollView {
                if searchText.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        StudentRecommendationsView(searchText: searchText)
                        CommunityView(searchText: searchText)
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(filteredStudents()) { student in
                            StudentCardView(student: student)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    private func filteredStudents() -> [DatabaseUser] {
        return users.filter { $0.userName.lowercased().contains(searchText.lowercased()) }
    }
}


struct HeaderView: View {
    @Binding var searchText: String

    var body: some View {
        VStack {
            HStack {
                SearchBar(searchText: $searchText)
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(radius: 0.1)
        }
    }
}

struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search for courses, teachers, and more...", text: $searchText)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
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
            HStack {
                Text("My Recommendations")
                    .font(.title2)
                    .bold()
                Spacer()
            }
            .padding(.bottom, 8)

            LazyVStack(spacing: 16) {
                ForEach(filteredStudents()) { student in
                    StudentCardView(student: student)
                }
            }
        }
    }

    private func filteredStudents() -> [DatabaseUser] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.userName.lowercased().contains(searchText.lowercased()) }
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
                .padding(.bottom, 8)

            LazyVStack(spacing: 16) {
                ForEach(filteredCommunities()) { community in
                    CommunityCardView(community: community)
                }
            }
        }
    }

    private func filteredCommunities() -> [Community] {
        if searchText.isEmpty {
            return communities
        } else {
            return communities.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
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

let users = [
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
