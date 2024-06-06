import SwiftUI

struct ReviewView: View {
    @State private var comment: String = ""
    @State private var rating: Double = 0.0
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private let maxCommentLength = 200
    var liveClass: LiveClass
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Review and Comment for \(liveClass.name)")
                    .font(.title2)
                    .padding()

                TextEditor(text: $comment)
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding()
                    .onChange(of: comment) { newValue in
                        if newValue.count > maxCommentLength {
                            comment = String(newValue.prefix(maxCommentLength))
                            showError = true
                            errorMessage = "Comment can't exceed \(maxCommentLength) characters."
                        }
                    }

                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.bottom, 10)
                }

                HStack {
                    Text("Rating:")
                    Slider(value: $rating, in: 0...5, step: 1)
                    Text("\(Int(rating))/5")
                        .fontWeight(.bold)
                }
                .padding()

                Button(action: {
                    Task {
                        do {
                            try await submitReview()
                            dismiss()
                        } catch {
                            showError = true
                            errorMessage = "Failed to submit review: \(error.localizedDescription)"
                            print(errorMessage)
                        }
                    }
                }) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()

                Spacer()
            }
            .padding()
            .navigationTitle("Review \(liveClass.name)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func submitReview() async throws {
        let updatedBaseClass = try await ClassManager.shared.getBaseClass(classId: liveClass.classid)
        try await LiveClassManager.shared.confirmLiveClass(classId: liveClass.id)
        let newTotalReviews = Double(updatedBaseClass.reviews.count + 1)
        updatedBaseClass.rating = ((updatedBaseClass.rating * (newTotalReviews - 1)) + rating) / newTotalReviews
        updatedBaseClass.reviews.append(comment)
        try await ClassManager.shared.updateBaseClass(baseClass: updatedBaseClass)
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(liveClass: LiveClass(id: "1", name: "Sample Class", classid: "101", teacherId: "T1", studentId: "S1", date: Date(), duration: 60, note: "Sample Note"))
    }
}
