import SwiftUI
import SwiftData
import os

struct ContentView: View {
    
    @State private var selectedTab: NavigationItem? = .home
    
    @Environment(\.modelContext) private var modelContext
    @Query private var credentials: [Credential]
    @Query private var channels: [Channel]
    
    @StateObject private var channelManager = ChannelManager()
    @State private var showLiveTV = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    
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
    
    @ViewBuilder
    private var navigationContent: some View {
        #if os(tvOS) || os(macOS)
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            List {
                ForEach(NavigationItem.allCases) { item in
                    NavigationLink(
                        destination: navigationDestination(for: item),
                        tag: item,
                        selection: $selectedTab
                    ) {
                        Label(item.rawValue, systemImage: item.icon)
                    }
                }
            }
            .navigationTitle("Menu")
        } detail: {
            if let selectedTab = selectedTab {
                navigationDestination(for: selectedTab)
            } else {
                navigationDestination(for: .home)
            }
        }
        #elseif os(iOS)
        TabView(selection: Binding(
            get: { selectedTab ?? .home },
            set: { selectedTab = $0 }
        )) {
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
        #endif
    }
    
    @ViewBuilder
    private func navigationDestination(for tab: NavigationItem) -> some View {
        switch tab {
        case .home:
            HomeView(
                channels: channels,
                isLoading: isCheckingAPIReachability,
                onRefresh: handleFetchChannels
            )
        case .account:
            AccountView()
        case .live:
            LiveTVView()
        }
    }
    
    var body: some View {
        if credentials.isEmpty {
            SignInView()
        } else {
            navigationContent
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
