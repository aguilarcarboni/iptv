import Foundation
import SwiftData
import os

class ChannelManager: ObservableObject {
    @Published var channels: [Channel] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var lastResponseSample: String? = nil
    @Published var lastResponseType: String? = nil
    
    // Create a logger
    private let logger = Logger(subsystem: "com.anywhere.app", category: "ChannelManager")
    
    func fetchChannels(credentials: Credential, modelContext: ModelContext) {
        logger.info("Starting to fetch channels for user: \(credentials.username)")
        
        guard let url = URL(string: "\(credentials.serverUrl)/player_api.php?username=\(credentials.username)&password=\(credentials.password)&action=get_live_streams") else {
            let errorMsg = "Invalid URL constructed"
            logger.error("\(errorMsg)")
            self.error = errorMsg
            return
        }
        
        logger.info("Fetching channels from URL: \(url.absoluteString)")
        self.isLoading = true
        self.error = nil
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                // Log HTTP response
                if let httpResponse = response as? HTTPURLResponse {
                    self.logger.info("Received HTTP response with status code: \(httpResponse.statusCode)")
                    
                    // Log headers for debugging
                    let headers = httpResponse.allHeaderFields
                    self.logger.debug("Response headers: \(headers)")
                    
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
                
                // Safely analyze the JSON structure
                self.safelyAnalyzeResponse(data)
                
                // Delete existing channels before adding new ones
                do {
                    try self.deleteExistingChannels(modelContext: modelContext)
                } catch {
                    self.logger.error("Failed to delete existing channels: \(error.localizedDescription)")
                    // Continue anyway
                }
                
                // Try multiple decoding approaches
                if !self.tryDecodeAsArray(data, modelContext: modelContext) {
                    if !self.tryDecodeAsNestedArray(data, modelContext: modelContext) {
                        self.error = "Failed to decode channels with any known format"
                        self.logger.error("All decoding approaches failed")
                    }
                }
            }
        }
        
        // Start the network request
        task.resume()
        logger.info("Network request started")
    }
    
    // Try to decode the response as a direct array of channels
    private func tryDecodeAsArray(_ data: Data, modelContext: ModelContext) -> Bool {
        do {
            self.logger.info("Attempting to decode as direct array")
            let channelsData = try JSONDecoder().decode([ChannelResponse].self, from: data)
            self.logger.info("Successfully decoded \(channelsData.count) channels as direct array")
            
            self.processChannels(channelsData, modelContext: modelContext)
            return true
        } catch let decodingError {
            self.logger.error("Failed to decode as direct array: \(decodingError.localizedDescription)")
            return false
        }
    }
    
    // Try to decode the response as a dictionary with a nested array
    private func tryDecodeAsNestedArray(_ data: Data, modelContext: ModelContext) -> Bool {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // Look for arrays in the response
                for (key, value) in json {
                    if let channelsArray = value as? [[String: Any]] {
                        self.logger.info("Found channels array under key: \(key)")
                        
                        // Try to convert this array to JSON and decode
                        if let channelsData = try? JSONSerialization.data(withJSONObject: channelsArray, options: []) {
                            do {
                                let channelsData = try JSONDecoder().decode([ChannelResponse].self, from: channelsData)
                                self.logger.info("Successfully decoded \(channelsData.count) channels from nested array under key '\(key)'")
                                
                                self.processChannels(channelsData, modelContext: modelContext)
                                return true
                            } catch {
                                self.logger.error("Failed to decode nested array under key '\(key)': \(error.localizedDescription)")
                                // Continue to try other keys
                            }
                        }
                    }
                }
            }
        } catch {
            self.logger.error("Failed to parse JSON for nested array: \(error.localizedDescription)")
        }
        return false
    }
    
    private func safelyAnalyzeResponse(_ data: Data) {
        // First, try to log the raw data as a string
        if let responseString = String(data: data, encoding: .utf8) {
            let truncatedResponse = String(responseString.prefix(500))
            self.lastResponseSample = truncatedResponse
            self.logger.info("Raw response (truncated): \(truncatedResponse)")
        } else {
            self.lastResponseSample = "Unable to convert response to string"
            self.logger.warning("Unable to convert response data to string")
        }
        
        // Now try to parse as JSON, with error handling
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = jsonObject as? [String: Any] {
                self.lastResponseType = "Dictionary"
                self.logger.info("Response is a dictionary with \(dictionary.count) keys")
                
                // Check for error message
                if let errorMsg = dictionary["error"] as? String {
                    self.error = "API Error: \(errorMsg)"
                    self.logger.error("API returned error: \(errorMsg)")
                }
                
                // Log the keys
                self.logger.info("Dictionary keys: \(dictionary.keys.joined(separator: ", "))")
                
                // Safely try to pretty print a sample
                do {
                    // Take just a few keys to avoid large objects
                    var sampleDict: [String: Any] = [:]
                    var count = 0
                    for (key, value) in dictionary {
                        if count < 3 {
                            // For arrays, just include a count or first few items
                            if let array = value as? [Any] {
                                if array.count > 3 {
                                    sampleDict[key] = "Array with \(array.count) items"
                                } else {
                                    sampleDict[key] = array
                                }
                            } else {
                                sampleDict[key] = value
                            }
                            count += 1
                        } else {
                            break
                        }
                    }
                    
                    // Only try to pretty print if we have a valid dictionary
                    if !sampleDict.isEmpty {
                        let jsonData = try JSONSerialization.data(withJSONObject: sampleDict, options: .prettyPrinted)
                        if let prettyString = String(data: jsonData, encoding: .utf8) {
                            self.lastResponseSample = prettyString
                        }
                    }
                } catch {
                    self.logger.warning("Could not pretty print dictionary sample: \(error.localizedDescription)")
                    // Keep the raw sample we already set
                }
                
            } else if let array = jsonObject as? [Any] {
                self.lastResponseType = "Array"
                self.logger.info("Response is an array with \(array.count) items")
                
                // Safely try to pretty print a sample of the array
                do {
                    // Just take the first item or two to avoid large arrays
                    let sampleArray = array.prefix(2)
                    if !sampleArray.isEmpty {
                        let jsonData = try JSONSerialization.data(withJSONObject: Array(sampleArray), options: .prettyPrinted)
                        if let prettyString = String(data: jsonData, encoding: .utf8) {
                            self.lastResponseSample = prettyString
                        }
                    }
                } catch {
                    self.logger.warning("Could not pretty print array sample: \(error.localizedDescription)")
                    // Keep the raw sample we already set
                }
                
                // If it's an array of dictionaries, log the keys of the first item
                if let firstItem = array.first as? [String: Any] {
                    self.logger.info("First array item keys: \(firstItem.keys.joined(separator: ", "))")
                }
            } else {
                self.lastResponseType = "Other JSON (\(type(of: jsonObject)))"
                self.logger.warning("Response is JSON but not a dictionary or array")
            }
        } catch {
            self.lastResponseType = "Invalid JSON"
            self.logger.error("Failed to parse JSON: \(error.localizedDescription)")
        }
    }
    
    private func logDecodingError(_ error: DecodingError) {
        switch error {
        case .dataCorrupted(let context):
            self.logger.error("Data corrupted: \(context.debugDescription)")
        case .keyNotFound(let key, let context):
            self.logger.error("Key not found: \(key.stringValue) - \(context.debugDescription)")
        case .typeMismatch(let type, let context):
            self.logger.error("Type mismatch: \(type) - \(context.debugDescription)")
        case .valueNotFound(let type, let context):
            self.logger.error("Value not found: \(type) - \(context.debugDescription)")
        @unknown default:
            self.logger.error("Unknown decoding error: \(error.localizedDescription)")
        }
    }
    
    private func processChannels(_ channelsData: [ChannelResponse], modelContext: ModelContext) {
        for (index, channelData) in channelsData.enumerated() {
            let channel = Channel(
                num: channelData.num,
                name: channelData.name,
                streamType: channelData.stream_type,
                streamId: channelData.stream_id,
                streamIcon: channelData.stream_icon,
                epgChannelId: channelData.epg_channel_id,
                added: channelData.added,
                customSid: channelData.custom_sid,
                tvArchive: channelData.tv_archive,
                directSource: channelData.direct_source,
                tvArchiveDuration: channelData.tv_archive_duration,
                categoryId: channelData.category_id,
                categoryIds: channelData.category_ids,
                thumbnail: channelData.thumbnail
            )
            
            modelContext.insert(channel)
            
            // Log every 100 channels to avoid excessive logging
            if index % 100 == 0 || index == channelsData.count - 1 {
                self.logger.info("Inserted channel \(index+1)/\(channelsData.count): \(channel.name)")
            }
        }
        
        // Query to update the published channels
        do {
            self.logger.info("Fetching channels from SwiftData")
            let descriptor = FetchDescriptor<Channel>()
            self.channels = try modelContext.fetch(descriptor)
            self.logger.info("Successfully fetched \(self.channels.count) channels from SwiftData")
        } catch {
            self.logger.error("Failed to fetch channels from SwiftData: \(error.localizedDescription)")
        }
    }
    
    private func tryAlternativeDecoding(_ data: Data, modelContext: ModelContext) {
        // Try to decode as a dictionary with an array inside
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // Look for arrays in the response
                for (key, value) in json {
                    if let channelsArray = value as? [[String: Any]] {
                        self.logger.info("Found channels array under key: \(key)")
                        
                        // Try to convert this array to JSON and decode
                        if let channelsData = try? JSONSerialization.data(withJSONObject: channelsArray, options: []) {
                            do {
                                let channelsData = try JSONDecoder().decode([ChannelResponse].self, from: channelsData)
                                self.logger.info("Successfully decoded \(channelsData.count) channels from nested array")
                                
                                // Process channels
                                self.processChannels(channelsData, modelContext: modelContext)
                                self.error = nil
                                return
                            } catch {
                                self.logger.error("Failed to decode nested array: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        } catch {
            self.logger.error("Alternative decoding failed: \(error.localizedDescription)")
        }
    }
    
    func deleteExistingChannels(modelContext: ModelContext) throws {
        let descriptor = FetchDescriptor<Channel>()
        let existingChannels = try modelContext.fetch(descriptor)
        
        logger.info("Deleting \(existingChannels.count) existing channels")
        
        for channel in existingChannels {
            modelContext.delete(channel)
        }
        
        logger.info("Finished deleting existing channels")
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

// Channel Response struct for decoding JSON
struct ChannelResponse: Decodable {
    let num: Int
    let name: String
    let stream_type: String
    let stream_id: Int
    let stream_icon: String
    let epg_channel_id: String
    let added: String
    let custom_sid: String
    let tv_archive: Int
    let direct_source: String
    let tv_archive_duration: Int
    let category_id: String
    let category_ids: [Int]
    let thumbnail: String
    
    // Custom decoding to handle potential type mismatches
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle num which might be Int or String
        if let numInt = try? container.decode(Int.self, forKey: .num) {
            num = numInt
        } else if let numString = try? container.decode(String.self, forKey: .num),
                  let numInt = Int(numString) {
            num = numInt
        } else {
            num = 0 // Default value
        }
        
        // Handle name
        name = try container.decode(String.self, forKey: .name)
        
        // Handle stream_type
        stream_type = try container.decode(String.self, forKey: .stream_type)
        
        // Handle stream_id which might be Int or String
        if let streamIdInt = try? container.decode(Int.self, forKey: .stream_id) {
            stream_id = streamIdInt
        } else if let streamIdString = try? container.decode(String.self, forKey: .stream_id),
                  let streamIdInt = Int(streamIdString) {
            stream_id = streamIdInt
        } else {
            stream_id = 0 // Default value
        }
        
        // Handle stream_icon
        stream_icon = try container.decodeIfPresent(String.self, forKey: .stream_icon) ?? ""
        
        // Handle epg_channel_id
        epg_channel_id = try container.decodeIfPresent(String.self, forKey: .epg_channel_id) ?? ""
        
        // Handle added
        added = try container.decodeIfPresent(String.self, forKey: .added) ?? ""
        
        // Handle custom_sid
        custom_sid = try container.decodeIfPresent(String.self, forKey: .custom_sid) ?? ""
        
        // Handle tv_archive which might be Int, Bool, or String
        if let tvArchiveInt = try? container.decode(Int.self, forKey: .tv_archive) {
            tv_archive = tvArchiveInt
        } else if let tvArchiveBool = try? container.decode(Bool.self, forKey: .tv_archive) {
            tv_archive = tvArchiveBool ? 1 : 0
        } else if let tvArchiveString = try? container.decode(String.self, forKey: .tv_archive),
                  let tvArchiveInt = Int(tvArchiveString) {
            tv_archive = tvArchiveInt
        } else {
            tv_archive = 0 // Default value
        }
        
        // Handle direct_source
        direct_source = try container.decodeIfPresent(String.self, forKey: .direct_source) ?? ""
        
        // Handle tv_archive_duration which might be Int or String
        if let tvArchiveDurationInt = try? container.decode(Int.self, forKey: .tv_archive_duration) {
            tv_archive_duration = tvArchiveDurationInt
        } else if let tvArchiveDurationString = try? container.decode(String.self, forKey: .tv_archive_duration),
                  let tvArchiveDurationInt = Int(tvArchiveDurationString) {
            tv_archive_duration = tvArchiveDurationInt
        } else {
            tv_archive_duration = 0 // Default value
        }
        
        // Handle category_id which might be String or Int
        if let categoryIdString = try? container.decode(String.self, forKey: .category_id) {
            category_id = categoryIdString
        } else if let categoryIdInt = try? container.decode(Int.self, forKey: .category_id) {
            category_id = String(categoryIdInt)
        } else {
            category_id = "" // Default value
        }
        
        // Handle category_ids which might be an array of Ints or a single Int or String
        if let categoryIdsArray = try? container.decode([Int].self, forKey: .category_ids) {
            category_ids = categoryIdsArray
        } else if let categoryIdInt = try? container.decode(Int.self, forKey: .category_ids) {
            category_ids = [categoryIdInt]
        } else if let categoryIdString = try? container.decode(String.self, forKey: .category_ids),
                  let categoryIdInt = Int(categoryIdString) {
            category_ids = [categoryIdInt]
        } else {
            category_ids = [] // Default empty array
        }
        
        // Handle thumbnail
        thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail) ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case num
        case name
        case stream_type
        case stream_id
        case stream_icon
        case epg_channel_id
        case added
        case custom_sid
        case tv_archive
        case direct_source
        case tv_archive_duration
        case category_id
        case category_ids
        case thumbnail
    }
} 
