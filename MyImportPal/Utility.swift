//
//  Utility.swift
//  MyImportPal
//
//  Created by John Cunningham on 4/3/21.
//

import Foundation
import HealthKit
import SwiftUI

class Utility {
    
    class func getHKStatus(_ appState: AppState) {
        let hkAuthorisationStatus = getHKAuthorizationStatus()
        
        appState.isHealthDataAvailable = isHealthDataAvailable()
        appState.hkRequiresAuthentication = hkAuthorisationStatus == HKAuthorizationStatus.notDetermined
        appState.hkDenied = hkAuthorisationStatus == HKAuthorizationStatus.sharingDenied
    }
    
    class func parseCSV(fileURL: URL) throws -> ParsedCSV {
        let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
        guard fileContent.starts(with: "Date,Weight") else {
            throw CSVParsingError(title: "Unsupported File", message: "Only weight is supported in this version.")
        }
        
        guard let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            throw CSVParsingError(title: "Huh?", message: "Body mass is suddenly not supported!?")
        }
        
        let csv = ParsedCSV()
        csv.fileName = fileURL.relativeString
        var samples: [HKQuantitySample] = []
        let rows = fileContent.components(separatedBy: "\n")
        for row in rows {
            if (row.starts(with: "Date,Weight")) {
                continue
            }
            
            let columns = row.components(separatedBy: ",")
            if (columns.count != 2) {
                continue
            }
            
            guard let weight = Double(columns[1]) else {
                throw CSVParsingError(title: "Invalid File", message: "Invalid weight data found in file.")
            }
            
            let dateString = columns[0] + "T00:00:00+0000"
            guard let date = ISO8601DateFormatter().date(from: dateString) else {
                throw CSVParsingError(title: "Invalid File", message: "Invalid date found in file.")
            }
            
            let value = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
            let sample = HKQuantitySample(type: bodyMass, quantity: value, start: date, end: date)
            samples.append(sample)
        }
        
        csv.samples = samples.sorted { (a: HKQuantitySample, b: HKQuantitySample) -> Bool in
            a.startDate < b.startDate
        }
        
        csv.totalRecords = samples.count
        csv.startDate = samples.first?.startDate
        csv.endDate = samples.last?.startDate
        csv.recordsComplete = 0
        
        return csv
    }
    
    private class func getHKAuthorizationStatus() -> HKAuthorizationStatus {
        guard let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            return HKAuthorizationStatus.sharingDenied
        }
        
        let permission: HKAuthorizationStatus = HKHealthStore().authorizationStatus(for: bodyMass)
        return permission
    }
    
    private class func isHealthDataAvailable() -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }
        
        return true
    }
}

struct CSVParsingError: Error {
    var title: String
    var message: String
}

class ParsedCSV: Identifiable, ObservableObject {
    let id = UUID()
    
    @Published var totalRecords: Int = 0
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var fileName: String = ""
    @Published var recordsComplete = 0.0
    @Published var samples: [HKQuantitySample] = []
}
