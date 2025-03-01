import Foundation
import SwiftData

@Model
class Channel {
    var num: Int
    var name: String
    var streamType: String
    var streamId: Int
    var streamIcon: String
    var epgChannelId: String
    var added: String
    var customSid: String
    var tvArchive: Int
    var directSource: String
    var tvArchiveDuration: Int
    var categoryId: String
    var categoryIds: [Int]
    var thumbnail: String
    
    init(num: Int, name: String, streamType: String, streamId: Int, streamIcon: String, epgChannelId: String, added: String, customSid: String, tvArchive: Int, directSource: String, tvArchiveDuration: Int, categoryId: String, categoryIds: [Int], thumbnail: String) {
        self.num = num
        self.name = name
        self.streamType = streamType
        self.streamId = streamId
        self.streamIcon = streamIcon
        self.epgChannelId = epgChannelId
        self.added = added
        self.customSid = customSid
        self.tvArchive = tvArchive
        self.directSource = directSource
        self.tvArchiveDuration = tvArchiveDuration
        self.categoryId = categoryId
        self.categoryIds = categoryIds
        self.thumbnail = thumbnail
    }
} 