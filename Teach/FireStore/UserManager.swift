//
//  UserManager.swift
//  Teach
//
//  Created by Davie on 27/05/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DatabaseUser: Codable {
    let userId: String
    let email: String
    let photoUrl: String?
    let dateCreated: Date
    var userName: String
    var isTeacher: Bool
    var university: String
    var enrolledCourseNumber: Int
    var teachingCourseNumber: Int
    var tags: [String]
    var availability: String
    
    
    
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isTeacher = false
        self.university = ""
        self.enrolledCourseNumber = 0
        self.teachingCourseNumber = 0
        self.tags = []
        self.availability = ""
        self.userName = "Student"
    }
    
    mutating func updateTeacherStatus() {
        let currentValue = !isTeacher
        isTeacher = !currentValue
    }
    
    
}

final class UserManager {
    static let shared = UserManager()
    private init() {}
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func createNewUser(user: DatabaseUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
    }

    func getUser(userId: String) async throws -> DatabaseUser {
        try await userDocument(userId: userId).getDocument(as: DatabaseUser.self, decoder: decoder)
    }
    
    func updateUserTeacherStatus(userId: String, isTeacher: Bool) async throws {
        let data: [String: Any] = [
            "is_Teacher": isTeacher
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    
 


}
