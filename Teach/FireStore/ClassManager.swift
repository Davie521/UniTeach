//
//  BaseClass.swift
//  Teach
//
//  Created by Davie on 03/06/2024.
//

import Foundation

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
