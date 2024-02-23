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
