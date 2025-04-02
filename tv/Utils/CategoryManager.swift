import Foundation
import SwiftData
import os

class CategoryManager: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    // Create a logger
    private let logger = Logger(subsystem: "com.anywhere.app", category: "CategoryManager")
    
    func fetchCategories(credentials: Credential, modelContext: ModelContext) {
        logger.info("Starting to fetch categories for user: \(credentials.username)")
        
        guard let url = URL(string: "\(credentials.serverUrl)/player_api.php?username=\(credentials.username)&password=\(credentials.password)&action=get_live_categories") else {
            let errorMsg = "Invalid URL constructed"
            logger.error("\(errorMsg)")
            self.error = errorMsg
            return
        }
        
        logger.info("Fetching categories from URL: \(url.absoluteString)")
        self.isLoading = true
        self.error = nil
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                // Log HTTP response
                if let httpResponse = response as? HTTPURLResponse {
                    self.logger.info("Received HTTP response with status code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode != 200 {
                        let errorMsg = "Server returned non-200 status code: \(httpResponse.statusCode)"
                        self.logger.error("\(errorMsg)")
                        self.error = errorMsg
                        return
                    }
                }
                
                if let error = error {
                    let errorMsg = "Network Error: \(error.localizedDescription)"
                    self.logger.error("\(errorMsg)")
                    self.error = errorMsg
                    return
                }
                
                guard let data = data else {
                    let errorMsg = "No data received from server"
                    self.logger.error("\(errorMsg)")
                    self.error = errorMsg
                    return
                }
                
                self.logger.info("Received \(data.count) bytes of data")
                
                // Delete existing categories before adding new ones
                do {
                    try self.deleteExistingCategories(modelContext: modelContext)
                } catch {
                    self.logger.error("Failed to delete existing categories: \(error.localizedDescription)")
                    // Continue anyway
                }
                
                // Try to decode the categories
                do {
                    let categoriesData = try JSONDecoder().decode([CategoryResponse].self, from: data)
                    self.logger.info("Successfully decoded \(categoriesData.count) categories")
                    
                    self.processCategories(categoriesData, modelContext: modelContext)
                } catch {
                    self.logger.error("Failed to decode categories: \(error.localizedDescription)")
                    self.error = "Failed to decode categories: \(error.localizedDescription)"
                }
            }
        }
        
        task.resume()
        logger.info("Network request started")
    }
    
    private func processCategories(_ categoriesData: [CategoryResponse], modelContext: ModelContext) {
        for (index, categoryData) in categoriesData.enumerated() {
            let category = Category(
                categoryId: categoryData.category_id,
                categoryName: categoryData.category_name,
                parentId: categoryData.parent_id
            )
            
            modelContext.insert(category)
            
            // Log every 50 categories to avoid excessive logging
            if index % 50 == 0 || index == categoriesData.count - 1 {
                self.logger.info("Inserted category \(index+1)/\(categoriesData.count): \(category.categoryName)")
            }
        }
        
        // Query to update the published categories
        do {
            self.logger.info("Fetching categories from SwiftData")
            let descriptor = FetchDescriptor<Category>()
            self.categories = try modelContext.fetch(descriptor)
            self.logger.info("Successfully fetched \(self.categories.count) categories from SwiftData")
        } catch {
            self.logger.error("Failed to fetch categories from SwiftData: \(error.localizedDescription)")
        }
    }
    
    func deleteExistingCategories(modelContext: ModelContext) throws {
        let descriptor = FetchDescriptor<Category>()
        let existingCategories = try modelContext.fetch(descriptor)
        
        logger.info("Deleting \(existingCategories.count) existing categories")
        
        for category in existingCategories {
            modelContext.delete(category)
        }
        
        logger.info("Finished deleting existing categories")
    }
    
    // Helper method to check if the API is reachable
    func checkAPIReachability(credentials: Credential, completion: @escaping (Bool, String?) -> Void) {
        logger.info("Checking API reachability")
        
        guard let url = URL(string: "\(credentials.serverUrl)/") else {
            logger.error("Invalid base URL for reachability check")
            completion(false, "Invalid base URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] _, response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.logger.error("API reachability check failed: \(error.localizedDescription)")
                completion(false, "Network error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                self.logger.info("API reachability check returned status code: \(statusCode)")
                
                if 200...299 ~= statusCode {
                    completion(true, nil)
                } else {
                    completion(false, "Server returned status code: \(statusCode)")
                }
            } else {
                self.logger.error("API reachability check received invalid response")
                completion(false, "Invalid response from server")
            }
        }
        
        task.resume()
    }
} 