import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class BaseClass: Codable, Identifiable {
    var id: String
    var name: String
    var description: String
    var teacherId: String
    var price: Double
    var rating: Double = 0.0
    var reviews: [String] = []
    
    init(id: String, name: String, description: String, teacherId: String, price: Double, rating: Double, reviews: [String]) {
        self.id = id
        self.name = name
        self.description = description
        self.teacherId = teacherId
        self.price = price
        self.rating = rating
        self.reviews = reviews
    }
}

final class ClassManager {
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
        try await baseClassDocument(classId: classId).getDocument(as: BaseClass.self, decoder: decoder)
    }
    
    func fetchAllClasses() async throws -> [BaseClass] {
        let snapshot = try await baseClassCollection.getDocuments()
        return try snapshot.documents.map { try $0.data(as: BaseClass.self, decoder: decoder) }
    }
    
    func deleteBaseClass(baseClass: BaseClass) async throws {
        try await baseClassDocument(classId: baseClass.id).delete()
    }
    
    func getBaseClassOfUser(userId: String) async throws -> [BaseClass] {
        let snapshot = try await baseClassCollection.whereField("teacher_id", isEqualTo: userId).getDocuments()
        return try snapshot.documents.map { try $0.data(as: BaseClass.self, decoder: decoder) }
    }
    
    func updateBaseClass(baseClass: BaseClass) async throws {
        try baseClassDocument(classId: baseClass.id).setData(from: baseClass, merge: true, encoder: encoder)
    }
}
