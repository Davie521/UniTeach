import SwiftUI

@MainActor
class SettingsModel: ObservableObject {
    var user: DatabaseUser?
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


class ClassViewModel: ObservableObject {
    @Published var classes: [BaseClass] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchClasses() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetchedClasses = try await ClassManager.shared.fetchAllClasses()
            classes = fetchedClasses
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch classes: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func addClass(_ baseClass: BaseClass) async {
        do {
            try await ClassManager.shared.createBaseClass(baseClass: baseClass)
            await fetchClasses() // Refresh the class list
        } catch {
            errorMessage = "Failed to add class: \(error.localizedDescription)"
        }
    }

    func removeClass(_ baseClass: BaseClass) async {
        do {
            try await ClassManager.shared.deleteBaseClass(baseClass: baseClass)
            await fetchClasses() // Refresh the class list
        } catch {
            errorMessage = "Failed to remove class: \(error.localizedDescription)"
        }
    }
}

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showLogInView: Bool
    @StateObject private var settingsModel = SettingsModel()
    @StateObject private var classViewModel = ClassViewModel()
    @State private var newTag: String = ""
    @State private var newClass = BaseClass(id: UUID().uuidString, name: "", description: "", teacherId: "", price: 0.0)
    @State private var isEditingClass = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let user = settingsModel.user {
                    VStack(spacing: 15) {
                        profileSection(user: user)
                        classesSection()
                        saveButton
                    }
                    .padding()
                    .background(Color(.systemBackground).opacity(0.9))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
                } else if settingsModel.isLoading {
                    ProgressView()
                } else if let errorMessage = settingsModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                logOutButton
            }
            .padding()
            .navigationTitle("Settings")
            .task {
                await settingsModel.loadCurrentUser()
                await classViewModel.fetchClasses()
            }
            .sheet(isPresented: $isEditingClass) {
                EditClassView(baseClass: $newClass)
                    .onDisappear {
                        Task {
                            await classViewModel.fetchClasses()
                        }
                    }
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
                    settingsModel.user?.userName = newValue
                }
            ))
            .textFieldStyle(PlainTextFieldStyle())
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            
            TextField("University", text: Binding(
                get: { user.university },
                set: { newValue in
                    settingsModel.user?.university = newValue
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
        }
    }

    @ViewBuilder
    private func classesSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Classes")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Button(action: {
                newClass = BaseClass(id: UUID().uuidString, name: "", description: "", teacherId: settingsModel.user?.userId ?? "", price: 0.0)
                isEditingClass = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add New Class")
                }
            }
            .padding()

            if classViewModel.classes.isEmpty {
                Text("No classes available.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(classViewModel.classes) { baseClass in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(baseClass.name)
                                .font(.headline)
                            Text(baseClass.description)
                                .font(.subheadline)
                        }
                        Spacer()
                        Button(action: {
                            newClass = baseClass
                            isEditingClass = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
            }
        }
    }

    private var saveButton: some View {
        Button(action: {
            Task {
                do {
                    try await settingsModel.updateUser()
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
                    try settingsModel.logOut()
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
