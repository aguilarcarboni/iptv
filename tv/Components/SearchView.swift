import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    
    let searchSuggestions = [
        "Movies", "Sports", "News", "Kids Shows", "Documentaries", 
        "Live TV", "Music", "Comedy", "Drama", "Action"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search channels, shows, movies...", text: $searchText)
                    .font(.headline)
                    .padding(.vertical, 10)
                    .onSubmit {
                        isSearching = true
                    }
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        isSearching = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
            )
            .padding()
            
            if isSearching && !searchText.isEmpty {
                // Search results
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 20) {
                        ForEach(1...10, id: \.self) { _ in
                            VStack(alignment: .leading) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .aspectRatio(16/9, contentMode: .fit)
                                    
                                    Image(systemName: "play.tv")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Text("Result for \"\(searchText)\"")
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .padding(.top, 5)
                            }
                        }
                    }
                    .padding()
                }
            } else {
                // Search suggestions
                VStack(alignment: .leading) {
                    Text("Popular Searches")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 15) {
                            ForEach(searchSuggestions, id: \.self) { suggestion in
                                Button(action: {
                                    searchText = suggestion
                                    isSearching = true
                                }) {
                                    Text(suggestion)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                .background(Color.gray.opacity(0.05).cornerRadius(10))
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}
