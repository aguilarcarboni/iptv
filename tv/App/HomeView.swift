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
            VStack(alignment: .leading, spacing: 30) {
                // Header with refresh
                HStack {
                    Text("Discover")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        onRefresh()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.accent)
                            .clipShape(Circle())
                    }
                    .disabled(isLoading)
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                
                // Error message if exists
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Loading indicator
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Spacer()
                    }
                }
                
                // Content rows
                ForEach(categories, id: \.self) { category in
                    contentRow(title: category)
                }
                
                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(Color.black.opacity(0.05).ignoresSafeArea())
    }
    
    @ViewBuilder
    private func contentRow(title: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(1...10, id: \.self) { index in
                        contentItem(title: "\(title) \(index)", 
                                   description: "Description for \(title.lowercased()) item \(index)")
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private func contentItem(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 200, height: 120)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(width: 200)
    }
}

#Preview {
    HomeView(channels: [], isLoading: false, error: nil, onRefresh: {})
}
