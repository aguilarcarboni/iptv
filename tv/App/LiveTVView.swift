import SwiftUI
import SwiftData
import AVKit
import os

struct LiveTVView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var credentials: [Credential]
    @Query private var channels: [Channel]
    
    @State private var selectedChannel: Channel? = nil
    @State private var selectedCategory: String? = nil
    @State private var isFullScreen = false
    @State private var player: AVPlayer? = nil
    
    // Group channels by category
    private var channelsByCategory: [String: [Channel]] {
        var result: [String: [Channel]] = [:]
        
        // Group by categoryId
        for channel in channels {
            let categoryName = getCategoryName(for: channel.categoryId) ?? "Uncategorized"
            if result[categoryName] == nil {
                result[categoryName] = []
            }
            result[categoryName]?.append(channel)
        }
        
        return result
    }
    
    // Get sorted category names
    private var sortedCategories: [String] {
        Array(channelsByCategory.keys).sorted()
    }
    
    // Helper function to get category name from ID
    private func getCategoryName(for categoryId: String) -> String? {
        return categoryId.isEmpty ? "Uncategorized" : categoryId
    }
    
    // Start streaming the selected channel
    private func startStreaming(channel: Channel) {
        guard let credential = credentials.first else {
            return
        }
        
        // Construct the stream URL
        let streamUrl = "\(credential.serverUrl)/live/\(credential.username)/\(credential.password)/\(channel.streamId).m3u8"
        
        if let url = URL(string: streamUrl) {
            // Create a new player
            let newPlayer = AVPlayer(url: url)
            self.player = newPlayer
            
            // Start playback
            newPlayer.play()
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side: Categories or Channels
            List {
                if let selectedCategory = selectedCategory {
                    // Show back button
                    Button(action: {
                        self.selectedCategory = nil
                        self.selectedChannel = nil
                        self.player = nil
                    }) {
                        Label("Categories", systemImage: "chevron.left")
                    }
                    
                    // Show channels for selected category
                    if let channelsInCategory = channelsByCategory[selectedCategory] {
                        ForEach(channelsInCategory) { channel in
                            Button(action: {
                                selectedChannel = channel
                                startStreaming(channel: channel)
                            }) {
                                ChannelRow(channel: channel)
                            }
                        }
                    }
                } else {
                    // Show categories
                    ForEach(sortedCategories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            HStack {
                                Text(category)
                                Spacer()
                                if let count = channelsByCategory[category]?.count {
                                    Text("\(count)")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: 400)
            
            // Right side: Player
            ZStack {
                Color.black
                
                if let player = player {
                    VideoPlayer(player: player)
                        .onAppear{
                            player.play()
                        }
                        .onDisappear{
                            player.pause()
                        }
                } else {
                    NoChannelSelectedView()
                }
                
                // Channel info overlay
                if let channel = selectedChannel, player != nil {
                    ChannelOverlay(
                        channel: channel,
                        isFullScreen: $isFullScreen,
                        categoryName: getCategoryName(for: channel.categoryId) ?? ""
                    )
                }
            }
        }
        .navigationTitle(selectedCategory ?? "Live TV")
    }
}

// MARK: - Supporting Views
struct ChannelRow: View {
    let channel: Channel
    
    var body: some View {
        HStack {
            ChannelIcon(iconURL: channel.streamIcon)
                .frame(width: 40, height: 40)
            
            Text(channel.name)
                .lineLimit(1)
        }
    }
}

struct ChannelIcon: View {
    let iconURL: String
    
    var body: some View {
        if let url = URL(string: iconURL), !iconURL.isEmpty {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "tv")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
            }
        } else {
            Image(systemName: "tv")
                .font(.system(size: 20))
                .foregroundColor(.gray)
        }
    }
}

struct NoChannelSelectedView: View {
    var body: some View {
        VStack {
            Image(systemName: "tv")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            Text("Select a channel to start watching")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.top)
        }
    }
}

struct ChannelOverlay: View {
    let channel: Channel
    @Binding var isFullScreen: Bool
    let categoryName: String
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                VStack(alignment: .leading) {
                    Text(channel.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(categoryName)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(.black.opacity(0.5))
                .cornerRadius(10)
                
                Spacer()
                
                Button {
                    isFullScreen.toggle()
                } label: {
                    Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        .font(.title2)
                }
                .padding()
                .background(.black.opacity(0.5))
                .cornerRadius(10)
            }
            .padding()
        }
        .foregroundColor(.white)
        .opacity(0.8)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Credential.self, Channel.self, configurations: config)
    
    // Create sample data
    let credential = Credential(serverUrl: "http://example.com", username: "user", password: "pass")
    container.mainContext.insert(credential)
    
    // Add sample channels
    for i in 1...10 {
        let channel = Channel(
            num: i,
            name: "Channel \(i)",
            streamType: "live",
            streamId: i,
            streamIcon: "",
            epgChannelId: "",
            added: "",
            customSid: "",
            tvArchive: 0,
            directSource: "",
            tvArchiveDuration: 0,
            categoryId: i % 3 == 0 ? "Sports" : (i % 2 == 0 ? "News" : "Entertainment"),
            categoryIds: [],
            thumbnail: ""
        )
        container.mainContext.insert(channel)
    }
    
    return NavigationStack {
        LiveTVView()
            .modelContainer(container)
    }
} 
