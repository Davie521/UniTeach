import SwiftUI

struct ClassDetailView: View {
    var baseClass: BaseClass
    @State private var showRegistrationView = false
    @State private var showAllReviews = false  // This will control the sheet presentation

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
                    HStack {
                        Text("Reviews")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()

                        Button("Show All") {
                            showAllReviews = true
                        }
                        .foregroundColor(Color.gray)
                    }
                    
                    let filteredReviews = baseClass.reviews.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                    let randomReviews = filteredReviews.shuffled().prefix(3)
                    
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
            .sheet(isPresented: $showRegistrationView) {
                RegisterClassView(baseClass: baseClass)
            }
            .sheet(isPresented: $showAllReviews) {
                AllReviewsView(reviews: baseClass.reviews)
            }
        }
    }
}
struct AllReviewsView: View {
    var reviews: [String]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(reviews, id: \.self) { review in
                    Text(review)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                }
            }
            .padding()
            .navigationTitle("All Reviews")
        }
    }
}

import SwiftUI

struct RegisterClassView: View {
    var baseClass: BaseClass
    @State private var selectedDate = Date()
    @State private var availableTimeSlots: [Date] = []
    @State private var selectedTimeSlot: Date? = nil
    @State private var duration = 60
    @State private var note = ""
    @State private var showAlert = false  // State to manage alert visibility
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding()
                    .onChange(of: selectedDate, perform: { _ in
                        fetchAvailableTimeSlots()
                    })
                
                Picker("Select Duration", selection: $duration) {
                    Text("20 min").tag(20)
                    Text("30 min").tag(30)
                    Text("60 min").tag(60)
                    Text("90 min").tag(90)
                    Text("120 min").tag(120)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: duration, perform: { _ in
                    fetchAvailableTimeSlots()
                })
                
                Text("Select Available Time Slot")
                    .font(.headline)
                
                if availableTimeSlots.isEmpty {
                    Text("No available time slots.")
                        .foregroundColor(.red)
                } else {
                    Picker("Select Time Slot", selection: $selectedTimeSlot) {
                        ForEach(availableTimeSlots, id: \.self) { timeSlot in
                            Text("\(timeSlot, formatter: timeFormatter)")
                                .tag(timeSlot as Date?)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
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
                .disabled(selectedTimeSlot == nil)  // Disable button if no time slot is selected
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Class Scheduled"),
                        message: Text("Your class has been successfully scheduled."),
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
            .onAppear(perform: fetchAvailableTimeSlots)  // Fetch available time slots when the view appears
        }
    }
    
    private func fetchAvailableTimeSlots() {
        let teacherId = baseClass.teacherId
        
        Task {
            do {
                let user = try await UserManager.shared.getUser(userId: teacherId)
                let availability = user.availability  // assuming this returns [String: [TimeSlot]]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                let selectedDateString = dateFormatter.string(from: selectedDate)
                
                
                if let timeSlots = availability[selectedDateString] {
                    let calendar = Calendar.current
                    availableTimeSlots = generateTimeSlots(from: timeSlots, for: duration, on: selectedDate, using: calendar)
                } else {
                    availableTimeSlots = []
                }
            } catch {
                print("Failed to fetch user availability: \(error)")
                availableTimeSlots = []
            }
        }
    }
    
    private func generateTimeSlots(from timeSlots: [TimeSlot], for duration: Int, on date: Date, using calendar: Calendar) -> [Date] {
        var slots: [Date] = []
        
        for timeSlot in timeSlots {
            guard let startTime = calendar.date(from: timeSlot.startTime),
                  let endTime = calendar.date(from: timeSlot.endTime) else { continue }
            
            var slotTime = startTime
            while slotTime.addingTimeInterval(TimeInterval(duration * 60)) <= endTime {
                slots.append(slotTime)
                slotTime = slotTime.addingTimeInterval(5 * 60)  // Increment by 5 minutes
            }
        }
        
        return slots
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
    
    private func createLiveClass() {
        guard let selectedTimeSlot = selectedTimeSlot else { return }
        let userID = UserDefaults.standard.string(forKey: "userID") ?? "No user ID found"
        let newLiveClass = LiveClass(
            id: UUID().uuidString,
            name: baseClass.name,
            classid: baseClass.id,
            teacherId: baseClass.teacherId,
            studentId: userID,
            date: selectedTimeSlot,
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
