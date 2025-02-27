import SwiftUI
import SwiftData

struct HomeView: View {
    var channels: [Channel]
    var isLoading: Bool
    var error: String?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var credentials: [Credential]
    
    let categories = [
        "Movies", "TV Shows", "Sports", "News", "Kids", "Music", "Documentaries"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if isLoading {
                    // Loading indicator
                    VStack {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        Text("Loading Channels...")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                } else if let error = error {
                    // Error message
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                            .padding()
                        Text("Error loading channels")
                            .font(.headline)
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                } else if channels.isEmpty {
                    // No channels message
                    VStack {
                        Image(systemName: "tv.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                            .padding()
                        Text("No Channels Found")
                            .font(.headline)
                        Text("Pull down to refresh or check your connection settings")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                } else {
                    // Featured channel carousel
                    VStack(alignment: .leading) {
                        Text("Featured Channels")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(Array(channels.prefix(10)), id: \.streamId) { channel in
                                    NavigationLink(destination: credentials.isEmpty ? nil : LivePlayerView(channel: channel, credentials: credentials[0])) {
                                        VStack(alignment: .leading) {
                                            ZStack {
                                                if let url = URL(string: channel.streamIcon), !channel.streamIcon.isEmpty {
                                                    AsyncImage(url: url) { image in
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: 280, height: 157)
                                                            .clipped()
                                                            .cornerRadius(10)
                                                            .shadow(radius: 5)
                                                    } placeholder: {
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(Color.gray.opacity(0.3))
                                                            .aspectRatio(16/9, contentMode: .fit)
                                                            .frame(width: 280)
                                                            .shadow(radius: 5)
                                                            .overlay(
                                                                ProgressView()
                                                            )
                                                    }
                                                } else {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color.gray.opacity(0.3))
                                                        .aspectRatio(16/9, contentMode: .fit)
                                                        .frame(width: 280)
                                                        .shadow(radius: 5)
                                                        .overlay(
                                                            Image(systemName: "tv.fill")
                                                                .font(.system(size: 40))
                                                                .foregroundColor(.white)
                                                        )
                                                }
                                            }
                                            
                                            Text(channel.name)
                                                .font(.headline)
                                                .lineLimit(1)
                                                .padding(.top, 5)
                                        }
                                        .padding(.vertical, 5)
                                        .frame(width: 280)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Channel grid
                    VStack(alignment: .leading) {
                        Text("All Channels")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 15)], spacing: 15) {
                            ForEach(channels, id: \.streamId) { channel in
                                NavigationLink(destination: credentials.isEmpty ? nil : LivePlayerView(channel: channel, credentials: credentials[0])) {
                                    VStack {
                                        if let url = URL(string: channel.streamIcon), !channel.streamIcon.isEmpty {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 160, height: 90)
                                                    .clipped()
                                                    .cornerRadius(8)
                                            } placeholder: {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 160, height: 90)
                                                    .overlay(
                                                        ProgressView()
                                                    )
                                            }
                                        } else {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 160, height: 90)
                                                .overlay(
                                                    Image(systemName: "tv.fill")
                                                        .font(.system(size: 30))
                                                        .foregroundColor(.white.opacity(0.7))
                                                )
                                        }
                                        
                                        Text(channel.name)
                                            .font(.caption)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 160)
                                            .padding(.top, 4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    HomeView(channels: [], isLoading: false, error: nil)
}
