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
    @State var waterIntake = 0
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Daily Stats")
                .font(.largeTitle)
                .bold()
                .padding()
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2), spacing: 20) {
                // TODO: have the goals change depending on their exercise, height, weight, etc.
                ForEach(manager.activities.sorted(by: { $0.value.id < $1.value.id }), id: \.key) { item in
                    ActivityCard(activity: item.value)
                }
                
            }
            .padding(.horizontal)
            
            // TODO: Have a message stating what the user is lacking the most
            // i.e. find the max percentage difference of user stat and their goal,
            // and print a message relating to that
            // e.g. if their worst stat is water intake, then print this:
            Text("Looks like you need to drink more water!")
                .font(.title)
                .padding()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        
        
        .analyticsScreen(name: "\(HomeView.self)", extraParameters: ["test1": "test1 value"])

    }
    
}

#Preview {
    HomeView()
}
