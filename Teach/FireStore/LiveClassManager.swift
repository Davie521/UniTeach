//
//  LiveClassManager.swift
//  Teach
//
//  Created by Davie on 05/06/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


class LiveClass: Codable, Identifiable {
    
    var id: String
    var name: String
    var classid: String
    var teacherId: String
    var studentId: String
    var date: Date
    var duration: Int
    var note: String
    
    init(id: String, name: String, classid: String, teacherId: String, studentId: String, date: Date, duration: Int, note: String) {
        self.id = id
        self.name = name
        self.classid = classid
        self.teacherId = teacherId
        self.studentId = studentId
        self.date = date
        self.duration = duration
        self.note = note
    }
}

final class LiveClassManager {
    static let shared = LiveClassManager()
    private init() {}
    
    private let liveClassCollection = Firestore.firestore().collection("liveClasses")
    
    private func liveClassDocument(classId: String) -> DocumentReference {
        liveClassCollection.document(classId)
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
    
    func createLiveClass(liveClass: LiveClass) async throws {
        try liveClassDocument(classId: liveClass.id).setData(from: liveClass, merge: false, encoder: encoder)
    }
    
    func getClassTeaching(userId: String) async throws -> [LiveClass] {
        let snapshot = try await liveClassCollection.whereField("teacher_id", isEqualTo: userId).getDocuments()
        return try snapshot.documents.map { try $0.data(as: LiveClass.self, decoder: decoder) }
    }
    
    func getClassLearning(userId: String) async throws -> [LiveClass] {
        let snapshot = try await liveClassCollection.whereField("student_id", isEqualTo: userId).getDocuments()
        return try snapshot.documents.map { try $0.data(as: LiveClass.self, decoder: decoder) }
    }
    
}
