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
    
    init() {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        
        let healthTypes: Set = [steps, calories]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchTodaySteps()
                fetchTodayCalories()
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
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate)  { _, result, error in
            let stepCount = self.safeQuantity(result: result, error: error, unit: .count())
            let activity = Activity(id: 0, title: "Steps Taken", subtitle: "Goal: 10,000", image: "figure.walk", amount: stepCount.formattedString())
            
            DispatchQueue.main.async {
                self.activities["steps"] = activity
            }
            
            print(stepCount.formattedString())
        }
        
        healthStore.execute(query)
                                      
    }
    
    func fetchTodayCalories() {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, result, error in
            let caloriesBurned = self.safeQuantity(result: result, error: error, unit: .kilocalorie())
            let activity = Activity(id: 1, title: "Calories Burned", subtitle: "Goal: 900", image: "flame", amount: caloriesBurned.formattedString())
            
            DispatchQueue.main.async {
                self.activities["caloriesBurned"] = activity
            }
            
            print(caloriesBurned.formattedString())
            
        }
        
        healthStore.execute(query)
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
