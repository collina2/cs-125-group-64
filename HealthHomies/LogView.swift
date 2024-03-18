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
    @State private var selectedFoodItem: Food = Food(id: 0, name: "null", calories: 0, carbs: 0, fat: 0, protein: 0, sugar: 0, servingSize: ServingSize(amount: 0, unit: "g"))
    @State private var selectedServingSize: ServingSize = ServingSize(amount: 1, unit: "g")
    @State private var foodSelections = [Food: ServingSize]()
    @EnvironmentObject var manager: HealthManager
    @StateObject var dbManager = FirestoreManager()
    
    @State private var servingSizes: [ServingSize] = []
    let servingProportions = ["Quarter", "Half", "Full"]
    @State private var servingSizeDivider: Int = 1
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            Text("Update water intake")
                .bold()
            
            HStack(spacing: 20) {
                Button(action: {
                    if waterIntake > 0 {
                        waterIntake -= 1
                        saveData(waterIntake, forKey: "waterIntake")
                        manager.activities["waterIntake"] = manager.createActivity(key: "waterIntake")
                        manager.updateOverallScore()
                    }
    
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
                    manager.updateOverallScore()
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
                VStack {
                    
                    List {
                        Section(header: Text("Nutrition")) {
                            Text("Cals: \(selectedFoodItem.calories / servingSizeDivider)")
                            Text("Protein: \(selectedFoodItem.protein / servingSizeDivider)g")
                            Text("Carbs: \(selectedFoodItem.carbs / servingSizeDivider)g")
                            Text("Fat: \(selectedFoodItem.fat / servingSizeDivider)g")
                            Text("Sugar: \(selectedFoodItem.sugar / servingSizeDivider)g")
                        }
                        .font(.caption)
                    }
                    .environment(\.defaultMinListRowHeight, 32)
                    
                    
                }
                .padding(.vertical)
                
                VStack(alignment: .center) {
                    VStack {
                        Text("Food Item")
                            .bold()
                        
                        if !dbManager.fetchedFoods.isEmpty {
                            Picker("Food Item", selection: $selectedFoodItem) {
                                ForEach(dbManager.fetchedFoods, id: \.id) { food in
                                    Text(food.name)
                                        .tag(food)
                                        .frame(alignment: .leading)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading) // Ensure the picker fills the width
                            .task {
                                selectedFoodItem = dbManager.fetchedFoods[0]
                            }
                            .onChange(of: selectedFoodItem) {
                                // Find the selected food item
                                if let selectedFood = dbManager.fetchedFoods.first(where: { $0 == selectedFoodItem }) {
                                    // Update the serving sizes based on the selected food item
                                    servingSizes = [
                                        ServingSize(amount: selectedFood.servingSize.amount / 4, unit: selectedFood.servingSize.unit),
                                        ServingSize(amount: selectedFood.servingSize.amount / 2, unit: selectedFood.servingSize.unit),
                                        selectedFood.servingSize
                                    ]
                                    // Update the selected serving size to the default (full serving size)
                                    selectedServingSize = servingSizes[2]
                                    servingSizeDivider = 1

                                }
                            }
                        }
                        
                        Divider() // Add a divider for separation

                        Text("Serving Size")
                            .bold()
                        if !servingSizes.isEmpty {
                            Picker("Serving Size", selection: $selectedServingSize) {
                                ForEach(Array(servingSizes.enumerated()), id: \.1) { index, size in
                                    Text("\(servingProportions[index]) (\(size.toString()))")
                                        .tag(size)
                                        .frame(alignment: .leading)
                                }
                            }
                            .onChange(of: selectedServingSize) {
                                let servingSizeDividers = [4, 2, 1]
                                servingSizeDivider = servingSizeDividers[servingSizes.firstIndex(of: selectedServingSize) ?? 2]
                            }
                            
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity, alignment: .leading) // Ensure the picker fills the width
                        }
                    }
                    
                    
                    Button(action: {
                        if selectedFoodItem.name != "null" {
                            let amount = selectedServingSize.amount + (foodSelections[selectedFoodItem]?.amount ?? 0)
                            foodSelections[selectedFoodItem] = ServingSize(amount: amount, unit: selectedServingSize.unit)
                            saveEncodedData(foodSelections, forKey: "foodSelections")
                            
                            // convert saved data to protein and carb amount:
                            manager.saveFoodDetails(fetchedFoods: dbManager.fetchedFoods)
                            
                            manager.activities["proteinConsumed"] = manager.createActivity(key: "proteinConsumed")
                            manager.activities["carbsConsumed"] = manager.createActivity(key: "carbsConsumed")
                            manager.updateOverallScore()
                            
                        }
                        
                    }) {
                        Text("Log Food")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
                .padding(.vertical) // Add padding to the VStack
                
            }
            
            
            Divider() // Add a divider for separation
            
            // Display selected food items and serving sizes
            List {
                Section(header: Text("Logged Food and Amount")) {
                    ForEach(foodSelections.sorted(by: { $0.key < $1.key }), id: \.key) { food, servingSize in
                        Text("\(food.name): \(servingSize.toString())")
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
            if let loadedData: [Food: ServingSize] = loadDecodedData(forKey: "foodSelections") {
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
