//
//  DocumentPicker.swift
//  MyImportPal
//
//  Created by John Cunningham on 3/3/21.
//

import SwiftUI
import Foundation

struct DocumentPicker: UIViewControllerRepresentable {
    var completion: ([URL]) -> Void
    
    init(action: @escaping ([URL]) -> Void) {
        self.completion = action
    }
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(completion: self.completion)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.text], asCopy: true)
        controller.delegate = (context as UIViewControllerRepresentableContext<DocumentPicker>).coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    var completion: ([URL]) -> Void
    
    init(completion: @escaping ([URL]) -> Void) {
        self.completion = completion
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.completion(urls)
    }
}
