//
//  Workspace.swift
//  MyImportPal
//
//  Created by John Cunningham on 3/3/21.
//

import SwiftUI
import HealthKit

struct Workspace: View {
    @EnvironmentObject var appState: AppState
    @State var buttonString = "Import"
    @State var isComplete = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var isImporting: Bool {
        get {
            if (isComplete) {
                return false
            }
            
            return appState.jobs.contains { (job) -> Bool in
                return job.recordsComplete > 0
            }
        }
    }
    
    fileprivate func getDateString(_ date: Date?) -> String {
        if date == nil {
            return "∞"
        }
        
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("d MMM")
        
        var s = f.string(from: date!)
        f.setLocalizedDateFormatFromTemplate("YYYY")
        s += "\n\(f.string(from: date!))"
        
        return s
    }
    
    fileprivate func JobView(_ job: ParsedCSV) -> some View {
        return VStack(spacing: 20) {
            HStack {
                Image(systemName: "scalemass.fill")
                Text("Weight")
                    .font(.title3)
                Spacer()
            }.foregroundColor(.accentColor)
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("First Entry")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .bold()
                    Text(getDateString(job.startDate))
                        .font(.body)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Last Entry")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .bold()
                    Text(getDateString(job.endDate))
                        .font(.body)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Total Entries")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .bold()
                    Text("\(job.totalRecords)")
                        .font(.system(size: 42))
                        .bold()
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            if (job.recordsComplete > 0) {
                ProgressView("Importing…", value: job.recordsComplete, total: Double(job.totalRecords))
            }
        }
        .padding(.all)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10.0)
    }
    
    var body: some View {
        
        if (!appState.hkRequiresAuthentication && appState.jobs.count < 1) {
            Button("Open File…") {
                self.appState.showFileSelector = true
            }
        }
        
        if (!appState.hkRequiresAuthentication && appState.jobs.count > 0) {
            ZStack {
                NavigationView {
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(self.appState.jobs) { job in
                                JobView(job).contextMenu {
                                    Button {
                                        DispatchQueue.main.async() {
                                            self.appState.jobs = []
                                        }
                                    } label: {
                                        Label("Remove", systemImage: "minus.circle")
                                    }
                                }
                            }
                        }
                        .navigationBarTitle("Data to import")
                        .padding()
                    }
                }
                .padding(.bottom, 65.0)
                
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            if (isComplete) {
                                self.appState.jobs = []
                                self.isComplete = false
                                self.buttonString = "Import"
                                return
                            }
                            
                            buttonString = "Importing…"
                            DispatchQueue.global(qos: .userInitiated).async {
                                for i in 0...self.appState.jobs.count - 1 {
                                    // Will need to split HK updates into batches?
                                    HKHealthStore().save(self.appState.jobs[i].samples) { (success, error) in
                                        if let error = error {
                                            print("Error saving Samples: \(error.localizedDescription)")
                                        } else {
                                            DispatchQueue.main.async() {
                                                // For now, just update the bar to 100% instantly
                                                self.appState.jobs[i].recordsComplete = Double(self.appState.jobs[i].totalRecords)
                                                buttonString = "Complete!"
                                                self.isComplete = true
                                            }
                                        }
                                    }
                                }
                            }
                        }) {
                            Text(buttonString).frame(maxWidth: .infinity)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(8)
                        .disabled(isImporting)
                    }.padding()
                }
            }
        }
    }
}
