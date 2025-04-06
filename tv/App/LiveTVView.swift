import SwiftUI
import SwiftData
import AVKit
import os

struct LiveTVView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var credentials: [Credential]
    
    // Use a more efficient approach for large data sets
    // Instead of querying all channels directly in the view
    @State private var loadedChannels: [Channel] = []
    @State private var loadedChannelsByCategory: [String: [Channel]] = [:]
    @State private var sortedCategories: [String] = []
    
    @State private var selectedChannel: Channel? = nil
    @State private var selectedCategory: String? = nil
    @State private var isFullScreen = false
    @State private var player: AVPlayer? = nil
    @State private var isLoading = true
    
    // Create a logger
    private let logger = Logger(subsystem: "com.anywhere.app", category: "LiveTVView")
    
    private func getCategoryName(for categoryId: String) -> String? {
        return categoryId.isEmpty ? "Uncategorized" : categoryId
    }
    
    private func startStreaming(channel: Channel) {
        guard let credential = credentials.first else { return }
        let streamUrl = "\(credential.serverUrl)/live/\(credential.username)/\(credential.password)/\(channel.streamId).m3u8"
        
        if let url = URL(string: streamUrl) {
            let newPlayer = AVPlayer(url: url)
            self.player = newPlayer
            newPlayer.play()
        }
    }
    
    // Function to efficiently load and categorize channels
    private func loadAndCategorizeChannels() {
        isLoading = true
        
        // Load channels in the background to avoid UI freezes
        DispatchQueue.global(qos: .userInitiated).async {
            let descriptor = FetchDescriptor<Channel>()
            
            do {
                // Get the channels
                let channels = try modelContext.fetch(descriptor)
                
                // Pre-process channels by category
                var channelsByCategory: [String: [Channel]] = [:]
                
                for channel in channels {
                    let categoryName = getCategoryName(for: channel.categoryId) ?? "Uncategorized"
                    if channelsByCategory[categoryName] == nil {
                        channelsByCategory[categoryName] = []
                    }
                    channelsByCategory[categoryName]?.append(channel)
                }
                
                // Sort categories
                let categories = Array(channelsByCategory.keys).sorted()
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    loadedChannels = channels
                    loadedChannelsByCategory = channelsByCategory
                    sortedCategories = categories
                    isLoading = false
                    logger.info("Loaded and categorized \(channels.count) channels into \(categories.count) categories")
                }
            } catch {
                logger.error("Failed to load channels: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            ScrollView {
                if isLoading {
                    VStack {
                        ProgressView()
                            .padding()
                        Text("Loading channels...")
                            .font(.caption)
                    }
                    .frame(width: 250)
                    .padding(.vertical, 40)
                } else {
                    VStack(spacing: 16) {
                        if let selectedCategory = selectedCategory {
                            
                            CustomButton(action: {
                                self.selectedCategory = nil
                                self.selectedChannel = nil
                                self.player = nil
                            }, label: "← Back to Categories")
                            .padding(.horizontal)
                            
                            // Channels in category
                            if let channelsInCategory = loadedChannelsByCategory[selectedCategory] {
                                LazyVStack {
                                    ForEach(channelsInCategory) { channel in
                                        
                                        VStack(alignment: .leading) {
                                            Text(channel.name)
                                            .font(.headline)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .onTapGesture {
                                                selectedChannel = channel
                                                startStreaming(channel: channel)
                                            }

                                            Text("Channel \(channel.num)")
                                            .font(.caption)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                        .background(selectedChannel?.id == channel.id ? Color("AccentColor").opacity(0.1) : Color.clear)
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        } else {
                            // Categories
                            LazyVStack {
                                ForEach(sortedCategories, id: \.self) { category in
                                    Button {
                                        selectedCategory = category
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(category)
                                                    .font(.callout)
                                                    .foregroundColor(Color("Foreground"))
                                                Text("\(loadedChannelsByCategory[category]?.count ?? 0) channels")
                                                    .font(.caption)
                                                    .foregroundColor(Color("Subtitle"))
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(Color("Subtitle"))
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if category != sortedCategories.last {
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .frame(width: 250)
            .background(Color("Background"))
            
            // Player view
            ZStack {
                Color("Background").opacity(0.9)
                
                if let player = player {
                    VideoPlayer(player: player)
                        .onAppear { player.play() }
                        .onDisappear { player.pause() }
                        .cornerRadius(16)
                        .padding(20)
                } else {
                    NoChannelSelectedView()
                }

            }
        }
        .navigationTitle(selectedCategory ?? "Live TV")
        .onAppear {
            loadAndCategorizeChannels()
        }
    }
}

// MARK: - Supporting Views
struct NoChannelSelectedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tv")
                .font(.system(size: 80))
                .foregroundColor(Color("Subtitle"))
            Text("No Channel Selected")
                .font(.title)
                .foregroundColor(Color("Subtitle"))

            Text("Select a channel from the sidebar to start watching")
                .font(.subheadline)
                .foregroundColor(Color("Subtitle"))
            .frame(maxWidth: 400)
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
            CustomCard(
                title: channel.name,
                description: categoryName,
                footer: "Channel \(channel.num)"
            )
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Credential.self, Channel.self, configurations: config)
    
    let credential = Credential(serverUrl: "http://example.com", username: "user", password: "pass")
    container.mainContext.insert(credential)
    
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
