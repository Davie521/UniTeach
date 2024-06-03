//
//  BaseClass.swift
//  Teach
//
//  Created by Davie on 03/06/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class BaseClass: Codable {
    var id: String
    var name: String
    var description: String
    var teacherId: String
    var price: Double
    
    init(id: String, name: String, description: String, teacherId: String, price: Double) {
        self.id = id
        self.name = name
        self.description = description
        self.teacherId = teacherId
        self.price = price
    }
}

class ClassManager {
    
    static let shared = ClassManager()
    
    private init() {}
    
    private let baseClassCollection = Firestore.firestore().collection("classes")
    
    private func baseClassDocument(classId: String) -> DocumentReference {
        baseClassCollection.document(classId)
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
    
    func createBaseClass(baseClass: BaseClass) async throws {
        try baseClassDocument(classId: baseClass.id).setData(from: baseClass, merge: false, encoder: encoder)
    }
    
    func getBaseClass(classId: String) async throws -> BaseClass {
        let documentSnapshot = try await baseClassDocument(classId: classId).getDocument()
        return try documentSnapshot.data(as: BaseClass.self, decoder: decoder)
    }
    
    func updateBaseClass(baseClass: BaseClass) async throws {
        try baseClassDocument(classId: baseClass.id).setData(from: baseClass, merge: true, encoder: encoder)
    }
    
    
    
    
}
