import SwiftUI
import AVKit

struct VideoPlayerView: View {
    private let player: AVPlayer
    
    init(url: URL) {
        self.player = AVPlayer(url: url)
        
        // Create player item with additional configuration
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
    
    }
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                player.play()
            }
    }
}
