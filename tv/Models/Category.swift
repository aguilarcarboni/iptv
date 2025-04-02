import Foundation
import SwiftData

@Model
class Category {
    var categoryId: String
    var categoryName: String
    var parentId: Int
    
    init(categoryId: String, categoryName: String, parentId: Int) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.parentId = parentId
    }
}

// Category Response struct for decoding JSON
struct CategoryResponse: Decodable {
    let category_id: String
    let category_name: String
    let parent_id: Int
    
    // Custom decoding to handle potential type mismatches
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle category_id which might be String or Int
        if let categoryIdString = try? container.decode(String.self, forKey: .category_id) {
            category_id = categoryIdString
        } else if let categoryIdInt = try? container.decode(Int.self, forKey: .category_id) {
            category_id = String(categoryIdInt)
        } else {
            category_id = "" // Default value
        }
        
        // Handle category_name
        category_name = try container.decode(String.self, forKey: .category_name)
        
        // Handle parent_id which might be Int or String
        if let parentIdInt = try? container.decode(Int.self, forKey: .parent_id) {
            parent_id = parentIdInt
        } else if let parentIdString = try? container.decode(String.self, forKey: .parent_id),
                  let parentIdInt = Int(parentIdString) {
            parent_id = parentIdInt
        } else {
            parent_id = 0 // Default value
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case category_id
        case category_name
        case parent_id
    }
} 