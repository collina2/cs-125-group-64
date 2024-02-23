//
//  HomeView.swift
//  HealthHomies
//
//  Created by Andrew Collins on 2/19/24.
//

import SwiftUI
import FirebaseAnalyticsSwift
import FirebaseAnalytics

struct HomeView: View {
    @EnvironmentObject var manager: HealthManager
    var body: some View {
        
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                ForEach(manager.activities.sorted(by: { $0.value.id < $1.value.id }), id: \.key) { item in
                    ActivityCard(activity: item.value)
                }
            }
            .padding(.horizontal)

        }

        .analyticsScreen(name: "\(HomeView.self)", extraParameters: ["test1": "test1 value"])

    }
}

#Preview {
    HomeView()
}
