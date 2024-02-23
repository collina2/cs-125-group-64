//
//  ContentView.swift
//  HealthHomies
//
//  Created by Rithvij Pochampally on 2/19/24.
//

import SwiftUI
import FirebaseAnalyticsSwift
import FirebaseAnalytics

struct ContentView: View {
    var body: some View {
        // TODO: have the user enter personal data here
        // e.g. height, weight, personal goals
        // you can also retrieve values from the Health app
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Coming soon...")
        }
        .padding()
        .analyticsScreen(name: "\(ContentView.self)", extraParameters: ["test2": "test2 value"])

    }
}

#Preview {
    ContentView()
}
