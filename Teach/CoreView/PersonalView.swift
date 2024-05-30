import SwiftUI

struct PersonalView: View {
    var showSettings = false
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                    
                    Text("Yifan Jiang")
                        .font(.title)
                        .fontWeight(.bold)
                    
                   
                }
                .padding(.top, 10)  // Adjust the top padding to position the avatar a bit higher
                
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Educational Details")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Institution")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Imperial College")
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Grade/Level")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Bachelor's Degree")
                            }
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
                                Text("12")
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Courses Teaching")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("3")
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
                                Text("Monday - Friday, 9am - 5pm")
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Timezone")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("UTC-5")
                            }
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding()
        }
        
    }
}

struct TagView: View {
    var tag: String
    
    var body: some View {
        Text(tag)
            .font(.caption)  // Make the tag font smaller
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
