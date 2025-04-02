import SwiftUI

struct TabItem: View {
    let key: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Text(key)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isSelected ? Color("Foreground") : Color("Subtitle"))
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
        }
        .background(isSelected ? Color("Background") : Color.clear)
        .cornerRadius(5)
        .onTapGesture(perform: action)
    }
}

struct TabsHeader: View {
    let tabs: [(String, AnyView)]
    let selectedTab: String
    let onTabSelect: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 10) {
                ForEach(tabs, id: \.0) { key, _ in
                    TabItem(
                        key: key,
                        isSelected: selectedTab == key,
                        action: { onTabSelect(key) }
                    )
                }
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
        }
        .background(Color("Muted"))
        .cornerRadius(8)
        .fixedSize(horizontal: true, vertical: false)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}

struct CustomTabs: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var selectedTab: String
    let tabs: [(String, AnyView)]
    let underlineColor: Color

    init(
        selectedTab: Binding<String>,
        tabs: [(String, AnyView)],
        underlineColor: Color = .white
    ) {
        self._selectedTab = selectedTab
        self.tabs = tabs
        self.underlineColor = underlineColor
    }

    var body: some View {
        VStack(spacing: 0) {
            TabsHeader(
                tabs: tabs,
                selectedTab: selectedTab,
                onTabSelect: { selectedTab = $0 }
            )
            
            if let selectedView = tabs.first(where: { $0.0 == selectedTab })?.1 {
                selectedView
            }
        }
    }
}

struct CustomTabs_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var selectedTab: String = "Tab A"

        let tabs: [(String, AnyView)] = [
            ("Tab A", AnyView(Text("Tab A content"))),
            ("Tab B", AnyView(Text("Tab B content")))
        ]

        var body: some View {
            CustomTabs(
                selectedTab: $selectedTab,
                tabs: tabs
            )
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
