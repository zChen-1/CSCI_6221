//
//  Swift_ASPApp.swift
//  Swift_ASP
//
//  Created by ZH Chen on 2024/10/16.
//

import SwiftUI

@main
struct Swift_ASPApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
