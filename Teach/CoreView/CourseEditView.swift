import SwiftUI

struct CourseEditView: View {
    @Binding var userCourses: [String]
    @State private var newCourse = ""

    var body: some View {
        VStack {
            List {
                ForEach(userCourses.indices, id: \.self) { index in
                    HStack {
                        TextField("Course Name", text: Binding(
                            get: { userCourses[index] },
                            set: { newValue in
                                userCourses[index] = newValue
                            }
                        ))
                        Spacer()
                    }
                }
                .onDelete(perform: deleteCourse)
            }

            HStack {
                TextField("New Course", text: $newCourse)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: addCourse) {
                    Text("Add")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Edit Courses")
        .toolbar {
            EditButton()
        }
    }

    private func addCourse() {
        if !newCourse.isEmpty {
            userCourses.append(newCourse)
            newCourse = ""
        }
    }

    private func deleteCourse(at offsets: IndexSet) {
        userCourses.remove(atOffsets: offsets)
    }
}

struct CourseEditView_Previews: PreviewProvider {
    static var previews: some View {
        CourseEditView(userCourses: .constant(["A level Maths", "A level Physics"]))
    }
}
