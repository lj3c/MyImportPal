//
//  HKNotAvailable.swift
//  MyImportPal
//
//  Created by John Cunningham on 3/3/21.
//

import SwiftUI

struct HKNotAvailable: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 128))
                        .frame(height: 150, alignment: .center)
                    Spacer()
                }
                
                Text("Health data is not available on this device!")
                    .font(.title)
                    .fontWeight(.heavy)
                
                Text("myimportpal needs access to HealthKit to write imported data and this device does not support it.\n\nWithout HealthKit, this app isn’t very useful. 😔")
                    .font(.body)
            }
            .padding()
        }
    }
}

struct HKNotAvailable_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HKNotAvailable()
            }
            .padding()
        }
    }
}
