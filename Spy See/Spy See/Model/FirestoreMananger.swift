//
//  FirestoreMananger.swift
//  Spot The Spy
//
//  Created by 楊哲維 on 2023/7/14.
//

import Foundation
import FirebaseFirestore

private let roomId: String? = UserDefaults.standard.string(forKey: "roomId")

class FirestoreManager {
    static let shared = FirestoreManager()
    private let dataBase = Firestore.firestore()
    func setData(collection: String = "Rooms", document: String = roomId ?? "", data: [String: Any], merge: Bool = false, completion: (() -> Void)? = nil) {
        let documentRef = dataBase.collection(collection).document(document)
        documentRef.setData(data, merge: merge) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
                completion?()
            }
        }
    }
    func getDocument(collection: String = "Rooms", document: String = roomId ?? "", completion: @escaping (Result<DocumentSnapshot?, Error>) -> Void) {
        let documentRef = dataBase.collection(collection).document(document)
        documentRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(document))
            }
        }
    }
    func updateData(collection: String = "Rooms", document: String = roomId ?? "", data: [String: Any], completion: (() -> Void)? = nil) {
        let documentRef = dataBase.collection(collection).document(document)
        documentRef.updateData(data) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document updated successfully")
                completion?()
            }
        }
    }
}
