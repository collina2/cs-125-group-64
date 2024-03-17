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

struct Food: Hashable {
    let id: Int
    let name: String
    let calories: Int
    let carbs: Int
    let fat: Int
    let protein: Int
    let sugar: Int
    let servingSize: String
    
    // Implementing hash(into:) method
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Implementing == method to compare two Food structs
    static func == (lhs: Food, rhs: Food) -> Bool {
        return lhs.id == rhs.id
    }
}

class FirestoreManager: ObservableObject {
    @Published var fetchedData: [[String : Any]] = []
    @Published var fetchedFoods: [Food] = []
    
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
    
    func fetchFoods() async {
        
        let query = foodsRef.order(by: "name", descending: false)
        
        do {
            let querySnapshot = try await query.getDocuments()
            
            fetchedFoods = querySnapshot.documents.compactMap { createFood(data: $0.data()) }
        } catch {
            print("Error getting documents: \(error)")
        }
    }
    
    func roundedInt(_ val: Any) -> Int {
        let roundedInt = ceil(Double(val as? Double ?? 0.0))
        return Int(roundedInt)
    }
    
    func toString(_ val: Any) -> String {
        return val as? String ?? "null"
    }
    
    func createFood(data: [String: Any]) -> Food {
        return Food(id: roundedInt(data["id"] ?? 0), name: toString(data["name"] ?? "null"), calories: roundedInt(data["calories"] ?? 0), carbs: roundedInt(data["carbs"] ?? 0), fat: roundedInt(data["fat"] ?? 0), protein: roundedInt(data["protein"] ?? 0), sugar: roundedInt(data["sugar"] ?? 0), servingSize: toString(data["serving_size"] ?? "null"))
    }
}
