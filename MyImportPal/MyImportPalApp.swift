//
//  MyImportPalApp.swift
//  MyImportPal
//
//  Created by John Cunningham on 1/3/21.
//

import SwiftUI
import HealthKit

@main
struct MyImportPalApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appState)
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                Utility.getHKStatus(appState)
                break
            case .inactive:
                break
            case .background:
                break
            @unknown default:
                break
            }
        }
    }
}

class AppState: ObservableObject {
    @Published var isHealthDataAvailable = false
    @Published var hkRequiresAuthentication = false
    @Published var hkDenied = false
    @Published var showFileSelector = false
    
    @Published var jobs: [ParsedCSV] = []
}
