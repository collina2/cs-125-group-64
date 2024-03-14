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
    
    // This is imported so the funcitions inside the class can be used
    @StateObject var dbManager = FirestoreManager()
    
    
    var body: some View {
        // TODO: have the user enter personal data here
        // e.g. height, weight, personal goals
        // you can also retrieve values from the Health app
        VStack {
            Image(systemName: "person")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("User Data")
            ForEach(manager.userData.sorted(by: { $0.key < $1.key }), id: \.key) { item in
                Text("\(item.key): \(item.value)")
            }
            Text("")
            
            
            Text("test query data")
            Button("Fetch Data") {
                //The next few lines just waits fort the function to be called, and then the data is printed to the console
                            Task {
                                await dbManager.fetchFirebaseData()
                            }
            }
            // Here it checks the fetchedData array from the TestQuery file and prints that out if it's not empty
            if !dbManager.fetchedData.isEmpty {
                            List(dbManager.fetchedData, id: \.self) { data in
                                Text(data) // Modify this according to your data structure
                            }
                        } else {
                            Text("No data fetched yet")
                                .foregroundColor(.gray)
                        }
        }
        .padding()
        .analyticsScreen(name: "\(ContentView.self)", extraParameters: ["test2": "test2 value"])

    }
}

#Preview {
    ContentView()
}
