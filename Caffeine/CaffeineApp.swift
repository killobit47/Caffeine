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
    @State var model = CaffeineViewModel()

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
                .environment(\.caffeineViewModel, model)
        } label: {
            Label("Caffeine", systemImage: model.isRuning ? "pill.fill" : "pill")
                .animation(.snappy, value: model.isRuning)
                .fontWeight(.black)
        }
        .menuBarExtraStyle(.window)
    }
}
