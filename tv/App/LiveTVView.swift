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
        for channel in channels {
            let categoryName = getCategoryName(for: channel.categoryId) ?? "Uncategorized"
            if result[categoryName] == nil {
                result[categoryName] = []
            }
            result[categoryName]?.append(channel)
        }
        return result
    }
    
    private var sortedCategories: [String] {
        Array(channelsByCategory.keys).sorted()
    }
    
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
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            ScrollView {
                VStack(spacing: 16) {
                    if let selectedCategory = selectedCategory {
                        
                        CustomButton(action: {
                            self.selectedCategory = nil
                            self.selectedChannel = nil
                            self.player = nil
                        }, label: "← Back to Categories")
                        .padding(.horizontal)
                        
                        // Channels in category
                        if let channelsInCategory = channelsByCategory[selectedCategory] {
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
                    } else {
                        // Categories
                        ForEach(sortedCategories, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(category)
                                            .font(.callout)
                                            .foregroundColor(Color("Foreground"))
                                        Text("\(channelsByCategory[category]?.count ?? 0) channels")
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
                .padding(.vertical)
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
    }
}

// MARK: - Supporting Views
struct NoChannelSelectedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tv")
                .font(.system(size: 80))
                .foregroundColor(Color("Subtitle"))
            
            CustomCard(
                title: "No Channel Selected",
                description: "Choose a channel from the sidebar to start watching"
            )
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
