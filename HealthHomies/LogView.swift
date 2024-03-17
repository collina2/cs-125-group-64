//
//  LogView.swift
//  HealthHomies
//
//  Created by Andrew Collins on 2/22/24.
//

import SwiftUI
import FirebaseAnalyticsSwift
import FirebaseAnalytics
import Foundation

struct LogView: View {
    @State private var waterIntake = 0
    @State private var selectedFoodItem = "Chicken"
    @State private var selectedServingSize = 0.5
    @State private var foodSelections = [String: Double]()
    @EnvironmentObject var manager: HealthManager
    
    let foodOptions = ["Chicken", "Orange", "Bread"]
    let servingSizes = [0.5, 1, 2] // Example serving sizes
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            Text("Update water intake")
                .font(.subheadline)
            
            HStack(spacing: 20) {
                Button(action: {
                    waterIntake -= 1
                    saveData(waterIntake, forKey: "waterIntake")
                    manager.activities["waterIntake"] = manager.createActivity(key: "waterIntake")
                    
                }) {
                    Image(systemName: "minus")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                
                Text("\(waterIntake) cups")
                    .font(.subheadline)
                
                Button(action: {
                    waterIntake += 1
                    saveData(waterIntake, forKey: "waterIntake")
                    manager.activities["waterIntake"] = manager.createActivity(key: "waterIntake")
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            
            Divider() // Add a divider for separation
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Food Item")
                    Picker("Food Item", selection: $selectedFoodItem) {
                        ForEach(foodOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure the picker fills the width
                    
                    Divider() // Add a divider for separation
                    
                    Text("Serving Size")
                    Picker("Serving Size", selection: $selectedServingSize) {
                        ForEach(servingSizes, id: \.self) { size in
                            Text("\(size.formattedServingSize())")
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure the picker fills the width
                }
                .padding() // Add padding to the VStack
                
                Button(action: {
                    foodSelections[selectedFoodItem] = selectedServingSize + (foodSelections[selectedFoodItem] ?? 0)
                    saveEncodedData(foodSelections, forKey: "foodSelections")
                }) {
                    Text("Log Food")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding() // Add padding to the Button
            }
            
            // Display selected food items and serving sizes
            VStack(alignment: .leading, spacing: 5) {
                ForEach(foodSelections.sorted(by: { $0.key < $1.key }), id: \.key) { food, servingSize in
                    Text("\(food): \(servingSize.formattedServingSize())")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .analyticsScreen(name: "\(LogView.self)", extraParameters: ["test3": "test3 value"])
        .onAppear {
            // Initialize data when the view appears
            if let loadedData: [String: Double] = loadDecodedData(forKey: "foodSelections") {
                foodSelections = loadedData
            }
            waterIntake = loadInt(forKey: "waterIntake") 
            
        }

    }
    
}


#Preview {
    LogView()
}

extension Double {
    func formattedServingSize() -> String {
        let size = self.formattedString()
        return size + " pounds"
    }
}
