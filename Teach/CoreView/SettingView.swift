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


struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showLogInView: Bool
    @StateObject private var model = SettingsModel()

    var body: some View {
        NavigationStack {
            List {
                if let user = model.user {
                    Section(header: Text("Profile")) {
                        TextField("Username", text: Binding(
                            get: { user.userName },
                            set: { newValue in
                                model.user?.userName = newValue
                            }
                        ))
                        TextField("University", text: Binding(
                            get: { user.university },
                            set: { newValue in
                                model.user?.university = newValue
                            }
                        ))
                        TextField("Email", text: .constant(user.email))
                            .disabled(true)
                        Toggle("Teacher", isOn: .constant(user.isTeacher))
                            .disabled(true)
                    }

                    Section {
                        Button("Save Changes") {
                            Task {
                                do {
                                    try await model.updateUser()
                                    dismiss()
                                } catch {
                                    print("Failed to update user: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                } else if model.isLoading {
                    ProgressView()
                } else if let errorMessage = model.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Section {
                    Button("Log Out") {
                        Task {
                            do {
                                try model.logOut()
                                showLogInView = true
                                dismiss()
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .task {
                await model.loadCurrentUser()
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(showLogInView: .constant(false))
    }
}
