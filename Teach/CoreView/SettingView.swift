import SwiftUI
import Combine

@MainActor
class SettingsModel: ObservableObject {
    @Published var user: DatabaseUser?
    @Published var classes: [BaseClass] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadCurrentUser() async {
        isLoading = true
        errorMessage = nil
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            user = try await UserManager.shared.getUser(userId: authDataResult.uid)
            if user != nil {
                try await fetchClasses()
            }
            isLoading = false
        } catch {
            errorMessage = "Failed to load user data: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func fetchClasses() async throws {
        do {
            classes = try await ClassManager.shared.getBaseClassOfUser(userId: user?.id ?? "")
        } catch {
            errorMessage = "Failed to fetch classes: \(error.localizedDescription)"
        }
    }

    func addClass(_ baseClass: BaseClass) async {
        do {
            try await ClassManager.shared.updateBaseClass(baseClass: baseClass)
            classes.append(baseClass)
        } catch {
            errorMessage = "Failed to add class: \(error.localizedDescription)"
        }
    }
    
    func updateClass(_ baseClass: BaseClass) async {
        do {
            try await ClassManager.shared.updateBaseClass(baseClass: baseClass)
            if let index = classes.firstIndex(where: { $0.id == baseClass.id }) {
                classes[index] = baseClass
            }
        } catch {
            errorMessage = "Failed to update class: \(error.localizedDescription)"
        }
        await loadCurrentUser()
    }

    func removeClass(_ baseClass: BaseClass) async {
        do {
            try await ClassManager.shared.deleteBaseClass(baseClass: baseClass)
            classes.removeAll { $0.id == baseClass.id }
        } catch {
            errorMessage = "Failed to remove class: \(error.localizedDescription)"
        }
    }

    func updateUser() async throws {
        guard let user = user else { return }
        try await UserManager.shared.updateUser(user: user)
    }

    func logOut() throws {
        try AuthenticationManager.shared.logOut()
        user = nil // Clear user data upon logout
        classes = [] // Clear classes as well
    }
    
    func addTag(_ tag: String) {
        guard var user = user, user.tags.count < 2, tag.count <= 10 else { return }
        user.tags.append(tag)
        self.user = user
    }
    
    func removeTag(_ tag: String) {
        user?.tags.removeAll { $0 == tag }
        self.user = user
    }
}




struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showLogInView: Bool
    @ObservedObject var settingsModel: SettingsModel
    @State private var newClass = BaseClass(id: UUID().uuidString, name: "", description: "", teacherId: "", price: 0.0, rating: 0.0, reviews: [])
    @State private var isEditingClass = false
    @State private var newTag: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = settingsModel.user {
                        classesSection()
                        tagsSection()
                        userSection(user: user)
                    } else if settingsModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else if let errorMessage = settingsModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    saveButton
                    logOutButton
                }
                .padding()
            }
            .navigationTitle("Settings")
            .task {
                await settingsModel.loadCurrentUser()
            }
            .sheet(isPresented: $isEditingClass) {
                EditClassView(baseClass: $newClass, settingsModel: settingsModel)
            }
        }
    }

    private func classesSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Classes")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Button(action: {
                newClass = BaseClass(id: UUID().uuidString, name: "", description: "", teacherId: settingsModel.user?.id ?? "", price: 0.0, rating: 0.0, reviews: [])
                isEditingClass = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add New Class")
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            ForEach(settingsModel.classes) { baseClass in
                classRow(for: baseClass)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }

    private func classRow(for baseClass: BaseClass) -> some View {
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
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }

    private func tagsSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tags")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if settingsModel.user?.tags.count ?? 0 < 2 {
                HStack {
                    TextField("New Tag", text: $newTag)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    
                    Button(action: {
                        if !newTag.isEmpty && newTag.count <= 10 {
                            settingsModel.addTag(newTag)
                            newTag = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.primary)
                            .font(.title2)
                    }
                }
                .padding(.bottom)
            }

            ForEach(settingsModel.user?.tags ?? [], id: \.self) { tag in
                tagRow(for: tag)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }

    private func tagRow(for tag: String) -> some View {
        HStack {
            Text(tag)
                .font(.body)
                .padding(5)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(5)
            
            Spacer()
            
            Button(action: {
                settingsModel.removeTag(tag)
            }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
        .padding(.vertical, 5)
    }

    private func userSection(user: DatabaseUser) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Profile")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            TextField("Username", text: Binding(
                get: { user.userName },
                set: { settingsModel.user?.userName = $0 }
            ))
            .textFieldStyle(PlainTextFieldStyle())
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            
            TextField("University", text: Binding(
                get: { user.university },
                set: { settingsModel.user?.university = $0 }
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
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }

    private var saveButton: some View {
        Button("Save Changes") {
            Task {
                do {
                    try await settingsModel.updateUser()
                    dismiss()
                } catch {
                    print("Failed to update user: \(error.localizedDescription)")
                }
            }
        }
        .buttonStyle(FilledButtonStyle())
    }

    private var logOutButton: some View {
        Button("Log Out") {
            Task {
                do {
                    try settingsModel.logOut()
                    showLogInView = true
                    dismiss()
                } catch {
                    print("Logout failed: \(error)")
                }
            }
        }
        .buttonStyle(FilledButtonStyle())
    }
}

struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primary)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(showLogInView: .constant(false), settingsModel: SettingsModel())
    }
}
