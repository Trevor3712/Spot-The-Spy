//
//  FirestoreMananger.swift
//  Spot The Spy
//
//  Created by 楊哲維 on 2023/7/14.
//

import Foundation
import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let dataBase = Firestore.firestore()
    func setData(collection: String, document: String, data: [String: Any], completion: (() -> Void)? = nil) {
        let documentRef = dataBase.collection(collection).document(document)
        documentRef.setData(data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
                completion?()
            }
        }
    }
}
