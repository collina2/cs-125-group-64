//
//  ContentView.swift
//  HealthHomies
//
//  Created by Rithvij Pochampally on 2/19/24.
//
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
    @State private var caloriesBurned: Double?
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Health Homies")

            if let calories = caloriesBurned {
                Text("Calories Burned: \(String(format: "%.2f", calories)) cal")
            } else {
                Button("Fetch Calories") {
                    fetchCalories()
                }
            }

            if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .analyticsScreen(name: "\(ContentView.self)")
    }

    func fetchCalories() {
        // Check if HealthKit is available on the device
        guard HKHealthStore.isHealthDataAvailable() else {
            DispatchQueue.main.async {
                self.errorMessage = "HealthKit is not available on this device"
            }
            return
        }

        let healthStore = HKHealthStore()

        // Request authorization for workout data (modify as needed)
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if success {
                // Set up a predicate to get all workouts for the current day
                let calendar = Calendar.current
                let now = Date()
                let startOfDay = calendar.startOfDay(for: now)
                let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictEndDate)

                // Set up a query to fetch all workouts for the current day
                let workoutType = HKObjectType.workoutType()
                let workoutQuery = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                    DispatchQueue.main.async {
                        if let workouts = results as? [HKWorkout] {
                            let totalCalories = workouts.reduce(0.0) { $0 + ($1.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0) }
                            print("Total Calories Burned: \(totalCalories) kcal")
                            self.caloriesBurned = totalCalories
                        }
                    }
                }

                healthStore.execute(workoutQuery)
            } else {
                // Handle authorization failure
                DispatchQueue.main.async {
                    self.errorMessage = "Authorization failed"
                }
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
