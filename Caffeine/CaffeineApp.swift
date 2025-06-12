//
//  CaffeineApp.swift
//  Caffeine
//
//  Created by Roman on 11.06.2025.
//

import SwiftUI
import ServiceManagement

@main
struct CaffeineApp: App {
    init() {
        do {
            try SMAppService.mainApp.register()
        } catch {
            print("Failed to register for launch at login: \(error)")
        }
    }

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .frame(width: 260)
        } label: {
            Label("Caffeine", systemImage: "pill.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
