//
//  UserManager.swift
//  Teach
//
//  Created by Davie on 27/05/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DatabaseUser {
    let userId: String
    let email: String
    let photoUrl: String?
    let dateCreated: Date
}

final class UserManager {
    static let shared = UserManager()
    private init() {}

    func createNewUser(auth: AuthDataResultModel) async throws {
        var userData: [String: Any] = [
            "user_id": auth.uid,
            "date_created": Timestamp(),
            "email": auth.email,
        ]
        if let photoUrl = auth.photoUrl {
            userData["photo_url"] = photoUrl
        }
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }

    func getUser(userId: String) async throws -> DatabaseUser {
        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()

        guard let data = snapshot.data(),
              let userId = data["user_id"] as? String,
              let email = data["email"] as? String,
              let dateCreatedTimestamp = data["date_created"] as? Timestamp else {
            throw URLError(.badServerResponse)
        }

        let dateCreated = dateCreatedTimestamp.dateValue()
        let photoUrl = data["photo_url"] as? String

        return DatabaseUser(userId: userId, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
    }
}
