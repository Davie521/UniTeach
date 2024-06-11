import SwiftUI

struct ClassDetailView: View {
    var baseClass: BaseClass
    @State private var showRegistrationView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Class Name
                Text(baseClass.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                    .multilineTextAlignment(.center)
                
                // Class Description
                VStack(alignment: .leading, spacing: 10) {
                    Text("Description")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(baseClass.description)
                        .font(.body)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal)
                
                // Rating View
                VStack(alignment: .leading, spacing: 10) {
                    Text("Rating")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    RatingView(rating: baseClass.rating)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal)
                
                // Reviews Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Reviews")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    let filteredReviews = baseClass.reviews.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                    let randomReviews = filteredReviews.shuffled().prefix(5)
                    
                    if randomReviews.isEmpty {
                        Text("No reviews available.")
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    } else {
                        ForEach(randomReviews, id: \.self) { review in
                            Text(review)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Enroll Button
                Button(action: {
                    showRegistrationView = true
                }) {
                    Text("Enroll")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding()
            .navigationTitle("Class Details")
        }
        .sheet(isPresented: $showRegistrationView) {
            RegisterClassView(baseClass: baseClass)
        }
    }
}

struct RegisterClassView: View {
    var baseClass: BaseClass
    @State private var selectedDate = Date()
    @State private var duration = 60
    @State private var note = ""
    @State private var showAlert = false  // State to manage alert visibility
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker("Select Date and Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding()
                
                Picker("Select Duration", selection: $duration) {
                    Text("20 min").tag(20)
                    Text("30 min").tag(30)
                    Text("60 min").tag(60)
                    Text("90 min").tag(90)
                    Text("120 min").tag(120)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                VStack(alignment: .leading) {
                    Text("Enter a note")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    TextEditor(text: $note)
                        .frame(height: 100)
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    createLiveClass()
                    showAlert = true  // Set showAlert to true to show the alert
                }) {
                    Text("Confirm")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Payment Success"),
                        message: Text("Your payment has been successfully processed."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func createLiveClass() {
        let userID = UserDefaults.standard.string(forKey: "userID") ?? "No user ID found"
        let newLiveClass = LiveClass(
            id: UUID().uuidString,
            name: baseClass.name,
            classid: baseClass.id,
            teacherId: baseClass.teacherId,
            studentId: userID,
            date: selectedDate,
            duration: duration,
            note: note
        )
        Task {
            do {
                try await LiveClassManager.shared.createLiveClass(liveClass: newLiveClass)
                dismiss()
            } catch {
                print("Failed to create live class: \(error)")
            }
        }
    }
}

struct ClassDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ClassDetailView(baseClass: BaseClass(id: "1", name: "Math 101", description: "Introduction to Algebra", teacherId: "1", price: 100.0, rating: 4.5, reviews: ["Great class!", "Very informative."]))
    }
}
