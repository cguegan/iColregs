//
//  iColregsApp.swift
//  iColregs
//
//  Created by Christophe Guégan on 18/06/2024.
//

import SwiftUI

@main
struct iColregsApp: App {
    @State private var appService = AppService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appService)
        }
    }
}
