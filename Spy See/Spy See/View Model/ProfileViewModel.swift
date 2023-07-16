//
//  ProfileViewModel.swift
//  Spot The Spy
//
//  Created by 楊哲維 on 2023/7/16.
//

import Foundation
import FirebaseAuth

enum ProfileError: Error {
    case userIdNotFound
    case documentNotFound
    case nameNotFound
}

class ProfileViewModel {
    func setNameData(name: String) {
        guard let userId = Auth.auth().currentUser?.email else {
            return
        }
        let data: [String: Any] = [
            "name": name
        ]
        FirestoreManager.shared.updateData(collection: "Users", document: userId, data: data)
    }
    func getUserName(completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.email else {
            completion(.failure(ProfileError.userIdNotFound))
            return
        }
        FirestoreManager.shared.getDocument(collection: "Users", document: userId) { result in
            switch result {
            case .success(let document):
                guard let document = document else {
                    completion(.failure(ProfileError.documentNotFound))
                    return
                }
                if let name = document.data()?["name"] as? String, !name.isEmpty {
                    completion(.success(name))
                } else {
                    completion(.failure(ProfileError.nameNotFound))
                }
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
    func deleteAuthData() {
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
            } else {
                print("Delete user successfully")
            }
        }
    }
    func deleteStoreData() {
        guard let userId = Auth.auth().currentUser?.email else {
            return
        }
        FirestoreManager.shared.delete(collection: "Users", document: userId)
    }
}
