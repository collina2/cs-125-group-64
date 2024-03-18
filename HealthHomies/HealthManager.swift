//
//  HealthManager.swift
//  HealthHomies
//
//  Created by Andrew Collins on 2/22/24.
//

import Foundation
import HealthKit

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

class HealthManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    
    @Published var activities: [String : Activity] = [:]
    @Published var userData: [String : HKQuantity] = [:]
    @Published var idCounter: Int = 0
        
    init() {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let height = HKQuantityType(.height)
        let weight = HKQuantityType(.bodyMass)
        
        let healthTypes: Set = [steps, calories, height, weight]
        
        activities["waterIntake"] = createActivity(key: "waterIntake")
        activities["proteinConsumed"] = createActivity(key: "proteinConsumed")
        activities["carbsConsumed"] = createActivity(key: "carbsConsumed")
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchTodaySteps()
                fetchTodayCalories()
                readMostRecentSample()
                updateOverallScore()
            } catch {
                print("error fetching health data")
            }
        }
        
    }
    
    private func safeQuantity(result: HKStatistics?, error: Error?, unit: HKUnit) -> Double {
        guard let quantity = result?.sumQuantity(), error == nil else {
            print("error fetching data: \(String(describing: error))")
            return 0
        }
        return quantity.doubleValue(for: unit)
    }
    
    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate)  { [self] _, result, error in
            let stepCount = self.safeQuantity(result: result, error: error, unit: .count())
            saveData(Int(stepCount), forKey: "steps")
            DispatchQueue.main.async { [self] in
                self.activities["steps"] = createActivity(key: "steps")
                updateOverallScore()
            }
            
            print(stepCount.formattedString())
        }
        
        healthStore.execute(query)
                                      
    }
    
    func fetchTodayCalories() {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { [self] _, result, error in
            let caloriesBurned = self.safeQuantity(result: result, error: error, unit: .kilocalorie())
            saveData(Int(caloriesBurned), forKey: "caloriesBurned")
            DispatchQueue.main.async { [self] in
                self.activities["caloriesBurned"] = createActivity(key: "caloriesBurned")
                updateOverallScore()
            }
            
            print(caloriesBurned.formattedString())
            
        }
        
        healthStore.execute(query)
    }
    
    func readMostRecentSample(){
        let weightType = HKSampleType.quantityType (forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!

        let queryWeight = HKSampleQuery(sampleType: weightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in

            if let result = results?.last as? HKQuantitySample {
                print("weight => \(result.quantity)")
                DispatchQueue.main.async {
                    self.userData["Weight"] = result.quantity
                }
            }
        }


        let queryHeight = HKSampleQuery(sampleType: heightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in

            if let result = results?.last as? HKQuantitySample {
                print("height => \(result.quantity)")
                DispatchQueue.main.async {
                    self.userData["Height"] = result.quantity
                }
            }
        }

        healthStore.execute(queryWeight)
        healthStore.execute(queryHeight)
    }
    
    // Function to increment idCounter and return its current value
    func getID() -> Int {
        idCounter += 1
        return idCounter
    }
    
    func saveFoodDetails(fetchedFoods: [Food] = []) {
        var foodSelections: [Food: ServingSize] = [:]
        if let loadedData: [Food: ServingSize] = loadDecodedData(forKey: "foodSelections") {
            foodSelections = loadedData
        }
        
        var proteinCount: Double = 0.0
        for (foodName, selectionValue) in foodSelections {
            // Find the corresponding Food struct in dbManager.fetchedFoods
            if let food = fetchedFoods.first(where: { $0.name == foodName.name }) {
                // Calculate the amount to add
                let amountFromSelection = Double(selectionValue.amount) / Double(food.servingSize.amount) * Double(food.protein)
                proteinCount += amountFromSelection
            }
        }
        saveData(Int(proteinCount), forKey: "proteinConsumed")
        
        var carbCount: Double = 0.0
        for (foodName, selectionValue) in foodSelections {
            // Find the corresponding Food struct in dbManager.fetchedFoods
            if let food = fetchedFoods.first(where: { $0.name == foodName.name }) {
                // Calculate the amount to add
                let amountFromSelection = Double(selectionValue.amount) / Double(food.servingSize.amount) * Double(food.carbs)
                carbCount += amountFromSelection
            }
        }
        saveData(Int(carbCount), forKey: "carbsConsumed")
    }
    
    func updateOverallScore() {
        var totalPercentage = 0
        var activityCount = 0

        for (key, activity) in activities {
            guard key != "overallScore", activity.goal != 0 else {
                continue // Skip overallScore and activities with goal = 0 to avoid division by zero
            }
            
            print("actest key: \(key), activity: \(activity)")
            
            var percentage = Int((Double(activity.amount) / Double(activity.goal)) * 100)
            if percentage > 100 {
                percentage = 100
            }
            totalPercentage += percentage
            activityCount += 1
        }

        let averagePercentage = activityCount > 0 ? totalPercentage / activityCount : 0
        saveData(Int(averagePercentage), forKey: "overallScore")
        activities["overallScore"] = createActivity(key: "overallScore")
    }
    
    func createActivity(key: String) -> Activity {
        let selectedFocusGoal = loadString(forKey: "selectedGoal") ?? "Overall"
        let amount = loadInt(forKey: key)
        
        
        var goal = 100
        var unit = "%"
        var image = "face.smiling"
        var title = "Overall Score"
        switch key {
        case "waterIntake":
            goal = 8
            if selectedFocusGoal == "Hydration" {
                goal = 10
            }
            title = "Water"
            unit = "cups"
            image = "waterbottle"
        case "proteinConsumed":
            goal = 60
            if selectedFocusGoal == "Strength" {
                goal = 80
            }
            title = "Protein"
            unit = "grams"
            image = "fork.knife.circle"
            
            
        case "carbsConsumed":
            goal = 200
            if selectedFocusGoal == "Diet" {
                goal = 100
            }
            title = "Carbohydrates"
            unit = "grams"
            image = "fork.knife.circle"
            
        case "caloriesBurned":
            goal = 900
            if selectedFocusGoal == "Cardio" {
                goal = 1200
            }
            title = "Calories Burned"
            unit = "cals"
            image = "flame"
        case "steps":
            goal = 10000
            if selectedFocusGoal == "Cardio" {
                goal = 15000
            }
            title = "Steps Taken"
            unit = "steps"
            image = "figure.walk"
        default: break
        }
        return Activity(id: getID(), title: title, goal: goal, image: image, amount: amount, unit: unit)
    }
    
    func getRecommendationString(title: String) -> String {
        switch title {
        case "Water":
            return "Drink more water"
        case "Steps Taken":
            return "Do some cardio (running, cycling, etc.)"
        case "Calories Burned":
            return "Burn some calories (weight-lifting, running, etc.)"
        case "Carbohydrates":
            return "Eat some carbs (bread, rice, etc.)"
        case "Protein":
            return "Eat some protein (chicken, cashews, etc.)"
        default:
            return "Exercise More"
        }
    }
}

extension Double {
    func formattedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
