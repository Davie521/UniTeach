import SwiftUI

final class PersonalViewModel: ObservableObject {
    @Published var user: DatabaseUser?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadCurrentUser() async {
        isLoading = true
        errorMessage = nil
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        } catch {
            errorMessage = "Failed to load user data: \(error.localizedDescription)"
        }
        isLoading = false
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

                    Text(user?.userName ?? "Default")
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
                                    Text(user?.university ?? "Imperial College")
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
                                    Text("\(String(describing: user?.enrolledCourseNumber))")
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Courses Teaching")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("\(String(describing: user?.teachingCourseNumber))")
                                }
                            }
                        }

                        Group {
                            Text("Tags and Specializations")
                                .font(.headline)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    TagView(tag: "Computer Science")
                                    TagView(tag: "Math")
                                    TagView(tag: "Physics")
                                    TagView(tag: "Further math")
                                }
                            }
                        }

                        Group {
                            Text("Availability")
                                .font(.headline)

                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Available Times")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(user?.availability ?? "Monday to Friday 9 - 17")
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .padding()
        }
        .task {
            await viewModel.loadCurrentUser()
        }
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

struct CombinedProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PersonalView()
        }
    }
}
