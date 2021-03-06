//
//  RequestHKAccess.swift
//  MyImportPal
//
//  Created by John Cunningham on 3/3/21.
//

import SwiftUI
import HealthKit

struct RequestHKAccess: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 128))
                        .frame(height: 150, alignment: .center)
                    Spacer()
                }
                
                Text("Allow myimportpal to access your fitness data?")
                    .font(.title)
                    .fontWeight(.heavy)
                
                Text("Your privacy is important to us, so this App will not record your personal health and fitness data anywhere except on your device, and your personal iCloud account.")
                    .font(.body)
                
                HStack {
                    Spacer()
                    Button("Grant Access…") {
                        guard let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
                            return
                        }

                        let healthKitTypesToRead: Set<HKObjectType> = [bodyMass]
                        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMass]

                        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (authorised, err) in
                            DispatchQueue.main.async() {
                                self.appState.hkRequiresAuthentication = false
                            }
                        }
                    }
                    Spacer()
                }
            }
            .padding()
        }
    }
}
