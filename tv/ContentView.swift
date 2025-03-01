import SwiftUI
import SwiftData
import os

struct ContentView: View {
    @State private var selectedTab: NavigationItem = .home
    @Environment(\.colorScheme) private var colorScheme
    
    @Environment(\.modelContext) private var modelContext
    @Query private var credentials: [Credential]
    @Query private var channels: [Channel]
    
    @StateObject private var channelManager = ChannelManager()
    @State private var showLiveTV = false
    
    private func handleFetchChannels() {
        guard !credentials.isEmpty else {
            return
        }
        channelManager.fetchChannels(credentials: credentials[0], modelContext: modelContext)
    }
    
    private func checkAPIReachability() {
        isCheckingAPIReachability = true
        
        channelManager.checkAPIReachability(credentials: credentials[0]) { reachable, error in
            DispatchQueue.main.async {
                self.isCheckingAPIReachability = false
                self.apiReachable = reachable
                self.apiReachabilityError = error
            }
        }
    }
    
    // State for API reachability
    @State private var isCheckingAPIReachability = false
    @State private var apiReachable = true
    @State private var apiReachabilityError: String? = nil
    
    enum NavigationItem: String, CaseIterable, Identifiable {
        case home = "Home"
        case account = "Account"
        case live = "Live TV"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .account: return "person.fill"
            case .live: return "tv.fill"
            }
        }
    }
    
    var body: some View {
        if credentials.isEmpty {
            SignInView()
        } else {
            TabView(selection: $selectedTab) {
                HomeView(
                    channels: channels,
                    isLoading: isCheckingAPIReachability,
                    onRefresh: handleFetchChannels
                )
                    .tabItem {
                        Label(NavigationItem.home.rawValue,
                              systemImage: NavigationItem.home.icon)
                    }
                    .tag(NavigationItem.home)
                
                AccountView()
                    .tabItem {
                        Label(NavigationItem.account.rawValue,
                              systemImage: NavigationItem.account.icon)
                    }
                    .tag(NavigationItem.account)
                
                LiveTVView()
                    .tabItem {
                        Label(NavigationItem.live.rawValue,
                              systemImage: NavigationItem.live.icon)
                    }
                    .tag(NavigationItem.live)
            }
            .tint(.accent)
        }
    }
}

// Remove placeholder views here

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Credential.self, Channel.self, configurations: config)
    
    ContentView()
        .modelContainer(container)
}
