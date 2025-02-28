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
    
    // Create a logger
    private let logger = Logger(subsystem: "com.anywhere.app", category: "ContentView")
    
    // State for API reachability
    @State private var isCheckingAPIReachability = false
    @State private var apiReachable = true
    @State private var apiReachabilityError: String? = nil
    
    enum NavigationItem: String, CaseIterable, Identifiable {
        case home = "Home"
        case search = "Search"
        case account = "Account"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .search: return "magnifyingglass"
            case .account: return "person.fill"
            }
        }
    }
    
    var body: some View {
        if credentials.isEmpty {
            // User is not logged in, show SignInView
            SignInView()
        } else {
            // User is logged in, show main app interface
            NavigationSplitView {
                // Sidebar
                List {
                    ForEach(NavigationItem.allCases) { item in
                        NavigationLink(
                            destination: Group {
                                switch item {
                                case .home:
                                    HomeView(channels: channels, isLoading: channelManager.isLoading, error: channelManager.error)
                                case .search:
                                    SearchView()
                                case .account:
                                    AccountView()
                                }
                            },
                            isActive: Binding(
                                get: { selectedTab == item },
                                set: { if $0 { selectedTab = item } }
                            )
                        ) {
                            Label {
                                Text(item.rawValue)
                                    .font(.headline)
                            } icon: {
                                Image(systemName: item.icon)
                                    .foregroundColor(.accent)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("InternetProtocolTV")
            } detail: {
                // Content area
                ZStack {
                    
                    // API Reachability Error
                    if !apiReachable {
                        VStack {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                                .padding()
                            
                            Text("Cannot Connect to Server")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.bottom, 2)
                            
                            if let error = apiReachabilityError {
                                Text(error)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                            }
                            
                            Button(action: checkAPIReachability) {
                                HStack {
                                    if isCheckingAPIReachability {
                                        ProgressView()
                                            .padding(.trailing, 5)
                                    }
                                    Text("Retry Connection")
                                }
                                .padding()
                                .background(Color.accent)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(isCheckingAPIReachability)
                        }
                        .padding()
                        .background(Color(colorScheme == .dark ? .black : .white).opacity(0.9))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding()
                    } else {
                        // Empty detail view - content is now shown via NavigationLink
                        Text("Select an option from the sidebar")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .navigationTitle(selectedTab.rawValue)
            }
            .onAppear {
                logger.info("ContentView appeared, checking API reachability")
                checkAPIReachability()
            }
            .refreshable {
                // Allow manual refresh of channels
                if !credentials.isEmpty {
                    logger.info("Manual refresh triggered")
                    checkAPIReachability()
                    if apiReachable {
                        fetchChannels()
                    }
                }
            }
        }
    }
    
    private func checkAPIReachability() {
        isCheckingAPIReachability = true
        logger.info("Checking API reachability")
        
        channelManager.checkAPIReachability(credentials: credentials[0]) { reachable, error in
            DispatchQueue.main.async {
                self.isCheckingAPIReachability = false
                self.apiReachable = reachable
                self.apiReachabilityError = error
                
                logger.info("API reachability check result: \(reachable ? "reachable" : "unreachable")")
                
                if reachable {
                    // If API is reachable and we don't have channels yet, fetch them
                    if channels.isEmpty {
                        fetchChannels()
                    }
                } else {
                    logger.error("API unreachable: \(error ?? "unknown error")")
                }
            }
        }
    }
    
    private func fetchChannels() {
        guard !credentials.isEmpty else {
            logger.warning("Attempted to fetch channels but no credentials available")
            return
        }
        
        logger.info("Fetching channels for user: \(credentials[0].username)")
        channelManager.fetchChannels(credentials: credentials[0], modelContext: modelContext)
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Credential.self, Channel.self, configurations: config)
    
    ContentView()
        .modelContainer(container)
}
