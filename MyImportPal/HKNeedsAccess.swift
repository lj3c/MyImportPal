//
//  HKNeedsAccess.swift
//  MyImportPal
//
//  Created by John Cunningham on 4/3/21.
//

import SwiftUI

struct HKNeedsAccess: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("myimportpal needs access to HealthKit to allow it to write imported data.")
                    .font(.body)
                HStack {
                    Spacer()
                    if (appState.hkDenied) {
                        Button("Open Settings") {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        }.disabled(true)
                    } else {
                        Button("Let‘s Go") {
                            self.appState.hkRequiresAuthentication = false
                        }
                    }
                    Spacer()
                }
            }.padding()
        }
    }
}

struct HKNeedsAccess_Previews: PreviewProvider {
    static var previews: some View {
        // JC: Just some test data
        let env: AppState = {
            let env = AppState()
            env.isHealthDataAvailable = true
            env.hkRequiresAuthentication = false
            env.hkDenied = true
            env.showFileSelector = false
            return env
        }()
        
        HKNeedsAccess()
            .environmentObject(env)
    }
}
