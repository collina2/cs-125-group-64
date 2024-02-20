//
//  HomeView.swift
//  HealthHomies
//
//  Created by Andrew Collins on 2/19/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                ActivityCard()
                
                ActivityCard()
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    HomeView()
}
