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
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Health Homies")
        }
        .padding()
        .analyticsScreen(name: "\(ContentView.self)", extraParameters: ["test2": "test2 value"])

    }
}

#Preview {
    ContentView()
}
