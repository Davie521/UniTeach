//
//  classDetailView.swift
//  Teach
//
//  Created by Davie on 05/06/2024.
//

import SwiftUI

struct ClassDetailView: View {
    var baseClass: BaseClass

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
                    
                    if baseClass.reviews.isEmpty {
                        Text("No reviews available.")
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    } else {
                        ForEach(baseClass.reviews, id: \.self) { review in
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
                Spacer()
                // Enroll Button
                Button(action: {
                    enrollInClass(baseClass)
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
    }

    private func enrollInClass(_ baseClass: BaseClass) {
        // Handle class enrollment logic here
        print("Enrolled in \(baseClass.name)")
        print(UserDefaults.standard.string(forKey: "userID") ?? "No user ID found")
    }
}

struct ClassDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ClassDetailView(baseClass: BaseClass(id: "1", name: "Math 101", description: "Introduction to Algebra", teacherId: "1", price: 100.0, rating: 4.5, reviews: ["Great class!", "Very informative."]))
    }
}
