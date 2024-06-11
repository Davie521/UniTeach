//
//  UserManager.swift
//  Teach
//
//  Created by Davie on 27/05/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


struct TimeSlot: Codable {
    var startTime: Timestamp
    var endTime: Timestamp
}


struct DatabaseUser: Codable, Identifiable {
    var id: String
    let email: String
    var photoUrl: String?
    let dateCreated: Date
    var userName: String
    var isTeacher: Bool
    var university: String
    var enrolledCourseNumber: Int
    var teachingCourseNumber: Int
    var tags: [String]
    var availability: [String: [TimeSlot]]
    var baseClasses: [String] = []
    var weeklyPlan: WeeklyPlan

    
    init(auth: AuthDataResultModel) {
        self.id = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isTeacher = false
        self.university = ""
        self.enrolledCourseNumber = 0
        self.teachingCourseNumber = 0
        self.tags = []
        self.availability = [:]
        self.userName = "Student"
        self.baseClasses = []
        self.weeklyPlan = WeeklyPlan()
        
    }
    
    init(userId: String, userName: String, isTeacher: Bool, university: String, tags: [String]) {
        self.id = userId
        self.email = "test1@test.com"
        self.photoUrl = nil
        self.dateCreated = Date()
        self.userName = userName
        self.isTeacher = isTeacher
        self.university = university
        self.enrolledCourseNumber = 0
        self.teachingCourseNumber = 0
        self.tags = tags
        self.availability = [:]
        self.baseClasses = []
        self.weeklyPlan = WeeklyPlan()
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
        try userDocument(userId: user.id).setData(from: user, merge: false, encoder: encoder)
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
    func updateUser(user: DatabaseUser) async throws {
        try userDocument(userId: user.id).setData(from: user, merge: true, encoder: encoder)
        
    }
    
    func createBaseClass(userId: String, baseClass: BaseClass) async throws {
        var user = try await getUser(userId: userId)
        user.baseClasses.append(baseClass.id)
        try await updateUser(user: user)
    }
    
    func searchUsersByName(name: String) async throws -> [DatabaseUser] {
        let snapshot = try await userCollection
            .whereField("user_name", isGreaterThanOrEqualTo: name)
            .whereField("user_name", isLessThanOrEqualTo: name + "\u{f8ff}")
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: DatabaseUser.self, decoder: decoder) }
    }
    
    // get two random user in the database
    func getRecommandedUsers() async throws -> [DatabaseUser] {
        let snapshot = try await userCollection
            .limit(to: 2)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: DatabaseUser.self, decoder: decoder) }
    }
    
    func getMyId() -> String? {
        return UserDefaults.standard.string(forKey: "userID")
    }
    
    // Method to clear the User ID when logging out
    func logoutUser() {
        UserDefaults.standard.removeObject(forKey: "userID")
    }
    
    
    
    
    
}
