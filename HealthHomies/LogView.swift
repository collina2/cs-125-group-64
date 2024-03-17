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
    @State private var selectedFoodItem: String = ""
    @State private var selectedServingSize: ServingSize = ServingSize(amount: 1, unit: "g")
    @State private var foodSelections = [String: ServingSize]()
    @EnvironmentObject var manager: HealthManager
    @StateObject var dbManager = FirestoreManager()
    
    @State private var servingSizes: [ServingSize] = []
    
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
                    if !dbManager.fetchedFoods.isEmpty {
                        Picker("Food Item", selection: $selectedFoodItem) {
                            ForEach(dbManager.fetchedFoods, id: \.id) { food in
                                Text(food.name)
                                    .tag(food.name)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading) // Ensure the picker fills the width
                        .task {
                            selectedFoodItem = dbManager.fetchedFoods[0].name
                        }
                    }
                    
                    Divider() // Add a divider for separation
                    
                    // TODO: change serving size to match each food item
                    Text("Serving Size")
                    if !servingSizes.isEmpty {
                        Picker("Serving Size", selection: $selectedServingSize) {
                            ForEach(servingSizes, id: \.amount) { size in
                                Text(size.toString())
                                    .tag(size.amount)
                            }
                        }
                        .task {
                            selectedServingSize = ServingSize(amount: 1, unit: "g")
                            servingSizes.append(ServingSize(amount: 2, unit: "g"))
                            servingSizes.append(ServingSize(amount: 4, unit: "g"))
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading) // Ensure the picker fills the width
                    }
                }
                .padding() // Add padding to the VStack
                
                Button(action: {
                    if selectedFoodItem != "" {
                        let amount = selectedServingSize.amount + (foodSelections[selectedFoodItem]?.amount ?? 0)
                        foodSelections[selectedFoodItem] = ServingSize(amount: amount, unit: selectedServingSize.unit)
                        saveEncodedData(foodSelections, forKey: "foodSelections")
                        
                        // convert saved data to protein and carb amount:
                        manager.saveFoodDetails(fetchedFoods: dbManager.fetchedFoods)
                        
                        manager.activities["proteinConsumed"] = manager.createActivity(key: "proteinConsumed")
                        manager.activities["carbsConsumed"] = manager.createActivity(key: "carbsConsumed")
                        
                    }
                    
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
            List {
                Section(header: Text("Logged Food and Amount")) {
                    ForEach(foodSelections.sorted(by: { $0.key < $1.key }), id: \.key) { food, servingSize in
                        Text("\(food): \(servingSize.toString())")
                    }
                }
            }
            
            Divider()
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .analyticsScreen(name: "\(LogView.self)", extraParameters: ["test3": "test3 value"])
        .onAppear {
            // Initialize data when the view appears
            if let loadedData: [String: ServingSize] = loadDecodedData(forKey: "foodSelections") {
                foodSelections = loadedData
            }
            waterIntake = loadInt(forKey: "waterIntake")
            
            Task {
                await dbManager.fetchFoods()
            }
            
        }

    }
    
}


#Preview {
    LogView()
}

extension ServingSize {
    func toString() -> String {
        return "\(self.amount) \(self.unit)"
    }
}
