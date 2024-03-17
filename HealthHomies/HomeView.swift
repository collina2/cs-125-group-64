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
                ForEach(manager.activities.values.sorted(by: { $0.id > $1.id }), id: \.id) { activity in
                    ActivityCard(activity: activity)
                }
                
            }
            .padding(.horizontal)
            .onReceive(manager.$activities) { _ in
                // This block gets called whenever manager.activities changes
                // Add any additional logic here to refresh the view

            }
            
            // Recommendation System
            VStack(alignment: .leading) {
                List {
                    Section(header: Text("Recommendations")) { // Title for the list
                        ForEach(manager.activities.values.sorted(by: { Double($0.amount) / Double($0.goal) < Double($1.amount) / Double($1.goal) }).prefix(7), id: \.id) { activity in
                            if activity.title != "Overall Score" && activity.amount < activity.goal {
                                Text(manager.getRecommendationString(title: activity.title))
                            }
                        }
                    }
                }
            }
            .padding()
                
            

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            
        }
        
        
        .analyticsScreen(name: "\(HomeView.self)", extraParameters: ["test1": "test1 value"])

    }
    
}

#Preview {
    HomeView()
}
