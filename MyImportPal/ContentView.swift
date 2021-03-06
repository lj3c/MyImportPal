//
//  ContentView.swift
//  MyImportPal
//
//  Created by John Cunningham on 1/3/21.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var body: some View {
        let requestHKAccess = Binding(
            get: {
                self.appState.hkRequiresAuthentication &&
                    !self.appState.hkDenied && self.appState.isHealthDataAvailable},
            set: { newValue in }
        )
        
        if (!appState.isHealthDataAvailable) {
            HKNotAvailable()
        } else if (appState.hkRequiresAuthentication || appState.hkDenied) {
            HKNeedsAccess()
                .background(
                    EmptyView()
                        .sheet(isPresented: requestHKAccess) {
                            RequestHKAccess().environmentObject(appState)
                        }
                )
        } else {
            Workspace()
                .background(
                    EmptyView()
                        .sheet(isPresented: self.$appState.showFileSelector) {
                            DocumentPicker() { (urls) in
                                guard let url = urls.first else {
                                    return
                                }
                                
                                do {
                                    let result = try Utility.parseCSV(fileURL: url)
                                    appState.jobs.append(result)
                                } catch let error as CSVParsingError {
                                    showingAlert = true
                                    alertTitle = error.title
                                    alertMessage = error.message
                                } catch let error {
                                    showingAlert = true
                                    alertTitle = "Could Not Read File"
                                    alertMessage = error.localizedDescription
                                }
                            }
                        }
                )
                .alert(isPresented: self.$showingAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        // JC: Just some test data
        let env: AppState = {
            let env = AppState()
            env.isHealthDataAvailable = true
            env.hkRequiresAuthentication = false
            env.hkDenied = false
            env.showFileSelector = false
            
            let csv = ParsedCSV()
            csv.totalRecords = 4096
            csv.startDate = Date(timeIntervalSince1970: 1267692900)
            csv.endDate = Date(timeIntervalSince1970: 1614848100)
            csv.fileName = "foo.csv"
            csv.recordsComplete = 0
            env.jobs.append(csv)
            return env
        }()
        
        ContentView()
            .environmentObject(env)
    }
}



