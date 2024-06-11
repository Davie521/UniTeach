import SwiftUI
import Foundation
import Combine


extension DateComponents: Comparable {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        let lhsDate = Calendar.current.date(from: lhs)!
        let rhsDate = Calendar.current.date(from: rhs)!
        return lhsDate < rhsDate
    }

    public static func == (lhs: DateComponents, rhs: DateComponents) -> Bool {
        let lhsDate = Calendar.current.date(from: lhs)!
        let rhsDate = Calendar.current.date(from: rhs)!
        return lhsDate == rhsDate
    }
}

enum DayOfWeek: String, CaseIterable, Codable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
}

struct WeeklyTimeSlot: Codable, Identifiable {
    var id = UUID()
    var day: DayOfWeek
    var startTime: DateComponents
    var endTime: DateComponents
}

struct WeeklyPlan: Codable {
    var slots: [WeeklyTimeSlot] = []

    func slots(for day: DayOfWeek) -> [WeeklyTimeSlot] {
        return slots.filter { $0.day == day }
    }

    func isOverlapping(day: DayOfWeek, startTime: DateComponents, endTime: DateComponents, excluding slotID: UUID? = nil) -> Bool {
        for slot in slots(for: day) {
            if slot.id != slotID &&
                ((startTime >= slot.startTime && startTime < slot.endTime) ||
                 (endTime > slot.startTime && endTime <= slot.endTime) ||
                 (startTime <= slot.startTime && endTime >= slot.endTime)) {
                return true
            }
        }
        return false
    }
}

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"  // 24-hour format
        return formatter
    }()
    
    static func string(from components: DateComponents) -> String {
        guard let date = Calendar.current.date(from: components) else { return "" }
        return timeFormatter.string(from: date)
    }
}

class ScheduleModel: ObservableObject {
    @Published var weeklyPlan = WeeklyPlan()
    
    func loadUserSchedule(userId: String) async throws {
        let user = try await UserManager.shared.getUser(userId: userId)
        DispatchQueue.main.async {
            self.weeklyPlan = user.weeklyPlan
        }
    }

    func saveUserSchedule(userId: String) async throws {
        var user = try await UserManager.shared.getUser(userId: userId)
        user.weeklyPlan = self.weeklyPlan
        try await UserManager.shared.updateUser(user: user)
    }
    
    func addTimeSlot(day: DayOfWeek, startTime: DateComponents, endTime: DateComponents) -> Bool {
        if weeklyPlan.isOverlapping(day: day, startTime: startTime, endTime: endTime) {
            return false
        }
        let newSlot = WeeklyTimeSlot(day: day, startTime: startTime, endTime: endTime)
        withAnimation {
            weeklyPlan.slots.append(newSlot)
        }
        return true
    }
    
    func removeTimeSlot(slot: WeeklyTimeSlot) {
        withAnimation {
            weeklyPlan.slots.removeAll { $0.id == slot.id }
        }
    }
    
    func updateTimeSlot(slot: WeeklyTimeSlot, startTime: DateComponents, endTime: DateComponents) -> Bool {
        if weeklyPlan.isOverlapping(day: slot.day, startTime: startTime, endTime: endTime, excluding: slot.id) {
            return false
        }
        if let index = weeklyPlan.slots.firstIndex(where: { $0.id == slot.id }) {
            withAnimation {
                weeklyPlan.slots[index].startTime = startTime
                weeklyPlan.slots[index].endTime = endTime
            }
        }
        return true
    }
}

struct ScheduleView: View {
    @StateObject var scheduleModel = ScheduleModel()
    @State private var selectedDay: DayOfWeek = .monday
    @State private var newStartTime = Calendar.current.dateComponents([.hour, .minute], from: Date())
    @State private var newEndTime = Calendar.current.dateComponents([.hour, .minute], from: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!)
    @State private var showingAddSlot = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var editingSlot: WeeklyTimeSlot? = nil
    @State private var showingActionSheet = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(DayOfWeek.allCases, id: \.self) { day in
                        Section(header: Text(day.rawValue).font(.headline).padding(.vertical, 2)) {
                            ForEach(scheduleModel.weeklyPlan.slots(for: day), id: \.id) { slot in
                                SlotView(slot: slot)
                                    .swipeActions {
                                        Button("Edit") {
                                            self.selectedDay = day
                                            self.newStartTime = slot.startTime
                                            self.newEndTime = slot.endTime
                                            self.editingSlot = slot
                                            self.showingAddSlot = true
                                        }
                                        .tint(.blue)

                                        Button("Delete") {
                                            scheduleModel.removeTimeSlot(slot: slot)
                                            Task {
                                                await saveSchedule()
                                            }
                                        }
                                        .tint(.red)
                                    }
                            }
                        }
                    }
                }
                .navigationTitle("Weekly Schedule")
                .listStyle(InsetGroupedListStyle())
                
                Button(action: {
                    showingActionSheet = true
                }) {
                    Text("Add Time Slot")
                        .font(.headline)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(
                        title: Text("Select Day"),
                        message: Text("Choose the day to add a new time slot."),
                        buttons: DayOfWeek.allCases.map { day in
                            .default(Text(day.rawValue)) {
                                self.selectedDay = day
                                self.newStartTime = Calendar.current.dateComponents([.hour, .minute], from: Date())
                                self.newEndTime = Calendar.current.dateComponents([.hour, .minute], from: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!)
                                self.editingSlot = nil
                                self.showingAddSlot = true
                            }
                        } + [.cancel()]
                    )
                }
            }
            .sheet(isPresented: $showingAddSlot) {
                VStack {
                    DatePicker("Start Time", selection: Binding(
                        get: { Calendar.current.date(from: newStartTime) ?? Date() },
                        set: { newStartTime = Calendar.current.dateComponents([.hour, .minute], from: $0) }
                    ), displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: Binding(
                        get: { Calendar.current.date(from: newEndTime) ?? Date() },
                        set: { newEndTime = Calendar.current.dateComponents([.hour, .minute], from: $0) }
                    ), displayedComponents: .hourAndMinute)
                    Button("Save") {
                        if let slot = editingSlot {
                            if scheduleModel.updateTimeSlot(slot: slot, startTime: newStartTime, endTime: newEndTime) {
                                self.showingAddSlot = false
                                Task {
                                    await saveSchedule()
                                }
                            } else {
                                self.alertMessage = "The time slot overlaps with an existing slot."
                                self.showingAlert = true
                            }
                        } else {
                            if scheduleModel.addTimeSlot(day: selectedDay, startTime: newStartTime, endTime: newEndTime) {
                                self.showingAddSlot = false
                                Task {
                                    await saveSchedule()
                                }
                            } else {
                                self.alertMessage = "The time slot overlaps with an existing slot."
                                self.showingAlert = true
                            }
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                Task {
                    await loadSchedule()
                }
            }
        }
    }
    
    private func saveSchedule() async {
        guard let userId = UserManager.shared.getMyId() else {
            self.alertMessage = "User not found."
            self.showingAlert = true
            return
        }
        do {
            var user = try await UserManager.shared.getUser(userId: userId)
            user.weeklyPlan = scheduleModel.weeklyPlan
            try await UserManager.shared.updateUser(user: user)
        } catch {
            self.alertMessage = "Failed to save schedule: \(error.localizedDescription)"
            self.showingAlert = true
        }
    }

    private func loadSchedule() async {
        guard let userId = UserManager.shared.getMyId() else {
            self.alertMessage = "User not found."
            self.showingAlert = true
            return
        }
        do {
            let user = try await UserManager.shared.getUser(userId: userId)
            self.scheduleModel.weeklyPlan = user.weeklyPlan
        } catch {
            self.alertMessage = "Failed to load schedule: \(error.localizedDescription)"
            self.showingAlert = true
        }
    }
}

struct SlotView: View {
    var slot: WeeklyTimeSlot

    var body: some View {
        HStack {
            Text("\(DateFormatter.string(from: slot.startTime)) - \(DateFormatter.string(from: slot.endTime))")
                .font(.headline)
            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .cornerRadius(8)

    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
    }
}
