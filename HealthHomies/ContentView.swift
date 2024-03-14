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
    @State private var selectedGoal = "Strength"
    let goalOptions = ["Strength", "Diet", "Hydration"]
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person")
                    .font(.title)
                    .foregroundStyle(.tint)
                
                VStack {
                    Text("User Data:")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title)
                        .bold()
                    ForEach(manager.userData.sorted(by: { $0.key < $1.key }), id: \.key) { item in
                        Text("\(item.key): \(item.value)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            
            Divider()
            
            HStack {
                    
                    Text("Focus Goal:")
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(goalOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure the picker fills the width
                    .onChange(of: selectedGoal) {
                        saveData(selectedGoal, forKey: "selectedGoal")
       
                    }
                

            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .analyticsScreen(name: "\(ContentView.self)", extraParameters: ["test2": "test2 value"])
        .onAppear {
            selectedGoal = loadString(forKey: "selectedGoal") ?? goalOptions[0]
            print("loadData: \(loadString(forKey: "selectedGoal") ?? "not found")")
        }
    }
}

#Preview {
    ContentView()
}
