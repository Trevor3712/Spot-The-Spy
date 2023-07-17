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
    func setRoomId() -> String {
        guard let roomId = UserDefaults.standard.string(forKey: "roomId") else { return "" }
        return roomId
    }
    func setData(collection: String = "Rooms", key: String = "roomId", data: [String: Any], merge: Bool = false, completion: (() -> Void)? = nil) {
        guard let documentId = UserDefaults.standard.string(forKey: key) else { return }
        let documentRef = dataBase.collection(collection).document(documentId)
        documentRef.setData(data, merge: merge) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
                completion?()
            }
        }
    }
    func getDocument(collection: String = "Rooms", key: String = "roomId", completion: @escaping (Result<DocumentSnapshot?, Error>) -> Void) {
        guard let documentId = UserDefaults.standard.string(forKey: key) else { return }
        let documentRef = dataBase.collection(collection).document(documentId)
        documentRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(document))
            }
        }
    }
    func updateData(collection: String = "Rooms", key: String = "roomId", data: [String: Any], completion: (() -> Void)? = nil) {
        guard let documentId = UserDefaults.standard.string(forKey: key) else { return }
        let documentRef = dataBase.collection(collection).document(documentId)
        documentRef.updateData(data) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document updated successfully")
                completion?()
            }
        }
    }
    func addSnapShotListener(collection: String = "Rooms", key: String = "roomId", completion: @escaping (Result<DocumentSnapshot?, Error>) -> Void) -> ListenerRegistration {
        let documentId = UserDefaults.standard.string(forKey: key)
        let documentRef = dataBase.collection(collection).document(documentId ?? "")
        let documentListener = documentRef.addSnapshotListener { document, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(document))
            }
        }
        return documentListener
    }
    func delete(collection: String = "Rooms", key: String = "roomId") {
        guard let documentId = UserDefaults.standard.string(forKey: key) else { return }
        let documentRef = dataBase.collection(collection).document(documentId)
        documentRef.delete { error in
            if let error = error {
                print("Delete error：\(error.localizedDescription)")
            } else {
                print("Delete successfully")
            }
        }
    }
}
