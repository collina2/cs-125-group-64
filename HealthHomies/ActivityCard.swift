//
//  ActivityCard.swift
//  HealthHomies
//
//  Created by Andrew Collins on 2/19/24.
//

import SwiftUI

struct Activity {
    let id: Int
    let title: String
    let subtitle: String
    let image: String
    let amount: Int
    let unit: String
}

struct ActivityCard: View {
    @State var activity: Activity
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)
                .frame(height: 140) // Set fixed height here
            
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(activity.title)
                            .frame(height: 20)
                            .minimumScaleFactor(0.5)

                        
                        Text(activity.subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    
                    Spacer()
                    
                    Image(systemName: activity.image)
                        .foregroundColor(.green)
                }
                
                
                Text("\(activity.amount) \(activity.unit)")
                    .font(.system(size: 24))
            }
            .padding()
        }
        
    }
}

#Preview {
    ActivityCard(activity: Activity(id: 0, title: "Daily Steps", subtitle: "Goal: 10,000", image: "figure.walk", amount: 6545, unit: "steps"))
}
