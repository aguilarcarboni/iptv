import SwiftUI
import SwiftData

struct HomeView: View {
    var channels: [Channel]
    var isLoading: Bool
    var error: String?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var credentials: [Credential]
    
    var onRefresh: () -> Void
    
    let categories = [
        "Movies", "TV Shows", "Sports", "News", "Kids", "Music", "Documentaries"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Refresh Button
                HStack {
                    Spacer()
                    Button(action: {
                        onRefresh()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh Channels")
                        }
                        .padding()
                        .background(Color.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    HomeView(channels: [], isLoading: false, error: nil, onRefresh: {})
}
