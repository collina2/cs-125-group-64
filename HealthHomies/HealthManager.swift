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
        
        let overallScore = loadInt(forKey: "overallScore")
        activities["overallScore"] = Activity(id: getID(), title: "Overall Score", subtitle: "Goal: 100%", image: "face.smiling", amount: "\(overallScore)%")
        
        let waterIntake = loadInt(forKey: "waterIntake")
        activities["waterIntake"] = Activity(id: getID(), title: "Water", subtitle: "Goal: 8 cups", image: "waterbottle", amount: "\(waterIntake) cups")
        
        let proteinConsumed = loadInt(forKey: "proteinConsumed")
        activities["proteinConsumed"] = Activity(id: getID(), title: "Protein", subtitle: "Goal: 60 grams", image: "fork.knife.circle", amount: "\(proteinConsumed) grams")
        
        let carbsConsumed = loadInt(forKey: "carbsConsumed")
        activities["carbsConsumed"] = Activity(id: getID(), title: "Carbohydrates", subtitle: "Goal: 200 grams", image: "fork.knife.circle", amount: "\(carbsConsumed) grams")
        
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchTodaySteps()
                fetchTodayCalories()
                readMostRecentSample()
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
            let activity = Activity(id: getID(), title: "Steps Taken", subtitle: "Goal: 10,000", image: "figure.walk", amount: stepCount.formattedString())
            
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
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { [self] _, result, error in
            let caloriesBurned = self.safeQuantity(result: result, error: error, unit: .kilocalorie())
            let activity = Activity(id: getID(), title: "Calories Burned", subtitle: "Goal: 900", image: "flame", amount: caloriesBurned.formattedString())
            
            DispatchQueue.main.async {
                self.activities["caloriesBurned"] = activity
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
    
}

extension Double {
    func formattedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
