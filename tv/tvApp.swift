//
//  anywhereApp.swift
//  anywhere
//
//  Created by Andrés Aguilar on 11/29/24.
//

import SwiftUI
import SwiftData

@main
struct tvApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([Credential.self, Channel.self])
            let modelConfiguration = ModelConfiguration(schema: schema)
            
            container = try ModelContainer(for: schema, configurations: modelConfiguration)
        } catch {
            fatalError("Could not configure SwiftData container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
