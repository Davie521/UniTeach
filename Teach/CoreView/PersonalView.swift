import SwiftUI

struct PersonalView: View {
    // Create a list of courses
    @State private var userCourses = ["A level Maths", "A level Physics", "A level Chemistry", "A level Biology", "A level Computer Science", "A level Engineering"]
    
    var body: some View {
        VStack {
            // Top horizontal section with avatar and text details
            HStack {
                // Align the image to the right
                Image("avatar")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                    .frame(width: 100, height: 100)
                
                VStack(alignment: .leading) {
                    // Use the network manager to get user name
                    Text("Yifan")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Imperial College")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 20)
            }
            .padding(.top, 20)
            
            // Available courses section
            HStack {
                Spacer()
                Spacer()
                Text("My Courses")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                Spacer()
                // add a button to edit
                NavigationLink(destination: CourseEditView(userCourses: $userCourses)) {
                    Image(systemName: "pencil")
                        .font(.title2)
                        .padding()
                }
            }
            
            // Create a rolling list of courses
            ScrollView(.vertical) {
                VStack {
                    ForEach(userCourses, id: \.self) { course in
                        HStack {
                            Text(course)
                                .font(.title3)
                                .padding()
                            Spacer()
                        }
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                }
                .padding(.bottom, 20)
            }
            .frame(maxHeight: 140) // Adjust the height as needed
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
        )
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}

struct PersonalView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalView()
    }
}
