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

struct ContentView: View {
    @EnvironmentObject var manager: HealthManager
    
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
        }
        .padding()
        .analyticsScreen(name: "\(ContentView.self)", extraParameters: ["test2": "test2 value"])

    }
}

#Preview {
    ContentView()
}
