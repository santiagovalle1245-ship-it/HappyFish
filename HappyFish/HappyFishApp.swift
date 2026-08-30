//
//  HappyFishApp.swift
//  HappyFish
//
//  Created by Marcela Valle Aguirre on 29/08/26.
//

import SwiftUI
import CoreData

@main
struct HappyFishApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
