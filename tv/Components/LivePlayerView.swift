import SwiftUI
import AVKit

struct LivePlayerView: View {
    var channel: Channel
    var credentials: Credential
    
    @State private var isLoading = true
    @State private var error: String? = nil
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Loading stream...")
                        .foregroundColor(.white)
                        .padding(.top)
                }
            } else if let error = error {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("Error Loading Stream")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text(error)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Go Back") {
                        dismiss()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.top)
                }
            } else {
                // Construct the stream URL
                let streamUrl = "\(credentials.serverUrl)/live/\(credentials.username)/\(credentials.password)/\(channel.streamId).m3u8"
                
                if let url = URL(string: streamUrl) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            // Auto-play when view appears
                            AVPlayer(url: url).play()
                        }
                } else {
                    Text("Invalid stream URL")
                        .foregroundColor(.white)
                }
            }
        }
        .navigationTitle(channel.name)
        .onAppear {
            // Simulate loading - in a real app, you might want to check if the stream is valid
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isLoading = false
            }
        }
    }
}

#Preview {
    // Create a mock channel and credentials for preview
    let channel = Channel(
        num: 1,
        name: "Sample Channel",
        streamType: "live",
        streamId: 12345,
        streamIcon: "",
        epgChannelId: "",
        added: "",
        customSid: "",
        tvArchive: 0,
        directSource: "",
        tvArchiveDuration: 0,
        categoryId: "",
        categoryIds: [],
        thumbnail: ""
    )
    
    let credentials = Credential(
        serverUrl: "http://example.com",
        username: "user",
        password: "pass"
    )
    
    return NavigationStack {
        LivePlayerView(channel: channel, credentials: credentials)
    }
} 
