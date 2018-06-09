//
//  Category.swift
//  Umbrella
//
//  Created by Lucas Correa on 16/05/2018.
//  Copyright © 2018 Security First. All rights reserved.
//

import Foundation

class Category: Codable, TableProtocol {
    let name: String?
    let index: Float?
    var folderName: String?
    var categories: [Category]
    var segments: [Segment]
    var checkList: [CheckItem]
    
    init() {
        name = ""
        index = 0
        folderName = ""
        categories = []
        segments = []
        checkList = []
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "title"
        case index
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        index = try container.decode(Float.self, forKey: .index)
        folderName = ""
        categories = []
        segments = []
        checkList = []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(index, forKey: .index)
    }
    
    //
    // MARK: - TableProtocol
    var tableName: String = "category"
    
    func columns() -> [String : String] {
        let array = [
            "id":"Primary",
            "name": "String",
            "index": "Int",
            "parent":"Int"
        ]
        return array
    }
}
