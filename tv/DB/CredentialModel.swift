import Foundation
import SwiftData

@Model
class Credential {
    var serverUrl: String
    var username: String
    var password: String
    var dateCreated: Date
    
    init(serverUrl: String, username: String, password: String) {
        self.serverUrl = serverUrl
        self.username = username
        self.password = password
        self.dateCreated = Date()
    }
}
