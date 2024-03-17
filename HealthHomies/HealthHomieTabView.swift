//
//  HealthHomieTabView.swift
//  HealthHomies
//
//  Created by Andrew Collins on 2/19/24.
//

import SwiftUI

struct HealthHomieTabView: View {
    @EnvironmentObject var manager: HealthManager
    @State var selectedTab = "Home"
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag("Home")
                .tabItem {
                    Image(systemName: "house")
                }
                .environmentObject(manager)
            
            LogView()
                .tag("Log")
                .tabItem {
                    Image(systemName: "fork.knife.circle.fill")
                }
            
            ExerciseView()
                .tag("Exercise")
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                }
            
            ContentView()
                .tag("Content")
                .tabItem {
                    Image(systemName: "person")
                }
        }
    }
}

#Preview {
    HealthHomieTabView()
}
