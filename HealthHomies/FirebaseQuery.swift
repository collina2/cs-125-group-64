//
//  FirebaseQuery.swift
//  HealthHomies
//
//  Created by Rithvij Pochampally on 3/14/24.
//

import Foundation
import SwiftUI
import FirebaseAnalyticsSwift
import FirebaseAnalytics
import FirebaseCore
import FirebaseFirestore

let db = Firestore.firestore()
let exerciseRef = db.collection("Exercise")
let foodsRef = db.collection("Foods")

class FirestoreManager: ObservableObject {
    @Published var fetchedData: [[String : Any]] = []
    
    func fetchFirebaseData() async {
        
        //This query is what is used to get data
        //This link helps show how to query different things:
        // https://firebase.google.com/docs/firestore/query-data/queries
        // Ask Rithvij for any questions on how to query or for any help!
        let query = exerciseRef.whereField("muscle_groups", arrayContains: "Triceps")
        do {
            let querySnapshot = try await query.getDocuments()
            
            // This next line is just to add it to an array that can be read from other views as long as the FirestoreManager class is imported correctly
            fetchedData = querySnapshot.documents.compactMap { $0.data() } // Like a dictionary, just use the names in the firestore database (ex: name, id, muscle_groups, etc)
            for document in querySnapshot.documents {
                print("\(document.documentID) => \(document.data())")
            }
        } catch {
            print("Error getting documents: \(error)")
        }
    }
}
