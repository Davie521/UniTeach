import SwiftUI

@MainActor
class SettingsModel: ObservableObject {
    @Published var user: DatabaseUser?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadCurrentUser() async {
        isLoading = true
        errorMessage = nil
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            user = try await UserManager.shared.getUser(userId: authDataResult.uid)
            isLoading = false
        } catch {
            errorMessage = "Failed to load user data: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func updateUser() async throws {
        guard let user else { return }
        try await UserManager.shared.updateUser(user: user)
    }

    func logOut() throws {
        try AuthenticationManager.shared.logOut()
    }
}

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showLogInView: Bool
    @StateObject private var model = SettingsModel()
    @State private var newTag: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let user = model.user {
                    VStack(spacing: 15) {
                        profileSection(user: user)
                        tagsSection(user: user)
                        saveButton
                    }
                    .padding()
                    .background(Color(.systemBackground).opacity(0.9))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
                } else if model.isLoading {
                    ProgressView()
                } else if let errorMessage = model.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                logOutButton
            }
            .padding()
            .navigationTitle("Settings")
            .task {
                await model.loadCurrentUser()
            }
        }
    }

    @ViewBuilder
    private func profileSection(user: DatabaseUser) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Profile")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            TextField("Username", text: Binding(
                get: { user.userName },
                set: { newValue in
                    model.user?.userName = newValue
                }
            ))
            .textFieldStyle(PlainTextFieldStyle())
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            
            TextField("University", text: Binding(
                get: { user.university },
                set: { newValue in
                    model.user?.university = newValue
                }
            ))
            .textFieldStyle(PlainTextFieldStyle())
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            
            TextField("Email", text: .constant(user.email))
                .disabled(true)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            
            Toggle("Teacher", isOn: .constant(user.isTeacher))
                .disabled(true)
        }
    }

    @ViewBuilder
    private func tagsSection(user: DatabaseUser) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tags")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack {
                TextField("New Tag", text: $newTag)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                Button(action: {
                    guard !newTag.isEmpty else { return }
                    model.user?.tags.append(newTag)
                    newTag = ""
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 10)
            }
            
            ForEach(user.tags, id: \.self) { tag in
                HStack {
                    Text(tag)
                    Spacer()
                    Button(action: {
                        model.user?.tags.removeAll { $0 == tag }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            }
        }
    }

    private var saveButton: some View {
        Button(action: {
            Task {
                do {
                    try await model.updateUser()
                    dismiss()
                } catch {
                    print("Failed to update user: \(error.localizedDescription)")
                }
            }
        }) {
            Text("Save Changes")
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .foregroundColor(.white)
                .cornerRadius(15)
        }
    }

    private var logOutButton: some View {
        Button(action: {
            Task {
                do {
                    try model.logOut()
                    showLogInView = true
                    dismiss()
                } catch {
                    print(error)
                }
            }
        }) {
            Text("Log Out")
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.red, Color.orange]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .foregroundColor(.white)
                .cornerRadius(15)
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(showLogInView: .constant(false))
    }
}
