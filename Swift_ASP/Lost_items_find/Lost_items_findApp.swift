//
//  Lost_items_findApp.swift
//  Lost_items_find
//
//  Created by ZH Chen on 2024/11/18.
//

import SwiftUI

@main
struct Lost_items_findApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
