//
//  ContentView.swift
//  HealthHomies
//
//  Created by Rithvij Pochampally on 2/19/24.
//

import SwiftUI
import FirebaseAnalyticsSwift
import FirebaseAnalytics
import HealthKit
import FirebaseCore
import FirebaseFirestore

struct ContentView: View {
    @EnvironmentObject var manager: HealthManager
    @State private var selectedGoal = "Strength"
    let goalOptions = ["Strength", "Diet", "Hydration"]
    
    // This is imported so the funcitions inside the class can be used
    @StateObject var dbManager = FirestoreManager()
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person")
                    .font(.title)
                    .foregroundStyle(.tint)
                
                VStack {
                    Text("User Data:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title)
                        .bold()
                    ForEach(manager.userData.sorted(by: { $0.key < $1.key }), id: \.key) { item in
                        Text("\(item.key): \(item.value)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            
            Divider()

            Button("See List of Tricep Exercises") {
                //The next few lines just waits fort the function to be called, and then the data is printed to the console
                Task {
                    await dbManager.fetchFirebaseData()
                }
            }
            
            // Here it checks the fetchedData array from the FirebaseQuery file and prints that out if it's not empty
            if !dbManager.fetchedData.isEmpty {
                ForEach(dbManager.fetchedData.indices, id: \.self) { index in
                    let item = dbManager.fetchedData[index]
                    // Access the "name" key of each dictionary
                    Text(item["name"] as? String ?? "Unknown")
                }
            }
            
            Divider()
            
            HStack {
                    
                    Text("Focus Goal:")
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(goalOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure the picker fills the width
                    .onChange(of: selectedGoal) {
                        saveData(selectedGoal, forKey: "selectedGoal")
       
                    }
                

            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .analyticsScreen(name: "\(ContentView.self)", extraParameters: ["test2": "test2 value"])
        .onAppear {
            selectedGoal = loadString(forKey: "selectedGoal") ?? goalOptions[0]
            print("loadData: \(loadString(forKey: "selectedGoal") ?? "not found")")
        }
    }
}

#Preview {
    ContentView()
}
