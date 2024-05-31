import SwiftUI

struct SearchView: View {
    var body: some View {
        VStack {
            HeaderView()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    StudentRecommendationsView()
                    CommunityView()
                }
                .padding()
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

struct HeaderView: View {
    var body: some View {
        VStack {
            HStack {
                SearchBar()
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(radius: 0.1)
        }
    }
}

struct SearchBar: View {
    @State private var searchText = ""

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
                ForEach(students) { student in
                    StudentCardView(student: student)
                }
            }
        }
    }
}

struct StudentCardView: View {
    let student: Student

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AvatarView()
                VStack(alignment: .leading) {
                    Text(student.name)
                        .font(.headline)
                    Text(student.university)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Text(student.description)
                .font(.body)
                .lineLimit(2)
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

struct CommunityView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Community")
                .font(.title2)
                .bold()
                .padding(.bottom, 8)

            LazyVStack(spacing: 16) {
                ForEach(communities) { community in
                    CommunityCardView(community: community)
                }
            }
        }
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

struct Student: Identifiable {
    let id = UUID()
    let name: String
    let university: String
    let description: String
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

let students = [
    Student(name: "John Doe", university: "Harvard University", description: "John Doe is a highly talented student with a passion for math and physics."),
    Student(name: "Jane Smith", university: "Stanford University", description: "Jane Smith is a passionate student of English and Literature with a unique perspective."),
//    Student(name: "Michael Johnson", university: "MIT", description: "Michael Johnson is a highly knowledgeable and engaged student of History and Geography."),
//    Student(name: "Emily Davis", university: "UC Berkeley", description: "Emily Davis is a highly talented and passionate student of Biology and Chemistry."),
    // Add more students as needed
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
