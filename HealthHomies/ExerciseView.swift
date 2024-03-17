//
//  ExerciseView.swift
//  HealthHomies
//
//  Created by Andrew Collins on 3/17/24.
//

import SwiftUI

struct ExerciseView: View {
    @State private var waterIntake = 0
    @State private var selectedExercise: String = ""
    @State private var selectedRepAmount: Int = 0
    @State private var exerciseSelections = [String: Int]()
    @EnvironmentObject var manager: HealthManager
    @StateObject var dbManager = FirestoreManager()
    
    @State private var exerciseReps: [Int] = []
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Exercise")
                        .bold()
                    if !dbManager.fetchedExercises.isEmpty {
                        Picker("Exercise", selection: $selectedExercise) {
                            ForEach(dbManager.fetchedExercises, id: \.id) { exercise in
                                Text(exercise.name)
                                    .tag(exercise.name)
                                    .frame(alignment: .leading)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, maxHeight: 48, alignment: .leading) // Ensure the picker fills the width
                        .task {
                            selectedExercise = dbManager.fetchedExercises[0].name
                        }
                        .onChange(of: selectedExercise) {
                            // Find the selected food item
                            if let selectedExercise = dbManager.fetchedExercises.first(where: { $0.name == selectedExercise }) {
                                // Update the serving sizes based on the selected food item
                                exerciseReps = [
                                    selectedExercise.repetitions
                                ]
                                // Update the selected serving size to the default (full serving size)
                                selectedRepAmount = exerciseReps[0]

                            }
                        }
                    }
                    
                    Divider() // Add a divider for separation
                    
                    Text("Repetitions")
                        .bold()
                    if !exerciseReps.isEmpty {
                        Picker("Repetition", selection: $selectedRepAmount) {
                            ForEach(Array(exerciseReps.enumerated()), id: \.1) { index, rep in
                                Text("\(rep) reps")
                                    .tag(rep)
                                    .frame(alignment: .leading)
                            }
                        }
                        
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading) // Ensure the picker fills the width
                    }
                }
                .padding() // Add padding to the VStack
                
                Button(action: {
                    if selectedExercise != "" {
                        let reps = selectedRepAmount + (exerciseSelections[selectedExercise] ?? 0)
                        exerciseSelections[selectedExercise] = reps
                        saveEncodedData(exerciseSelections, forKey: "exerciseSelections")
                        
                        // TODO: update the cards with relevant info
//                        // convert saved data to protein and carb amount:
//                        manager.saveFoodDetails(fetchedFoods: dbManager.fetchedFoods)
//                        
//                        manager.activities["proteinConsumed"] = manager.createActivity(key: "proteinConsumed")
//                        manager.activities["carbsConsumed"] = manager.createActivity(key: "carbsConsumed")
                        
                    }
                    
                }) {
                    Text("Log Exercise")
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
                Section(header: Text("Logged Exercise and Repetitions")) {
                    ForEach(exerciseSelections.sorted(by: { $0.key < $1.key }), id: \.key) { exercise, reps in
                        Text("\(exercise): \(reps) reps")
                    }
                }
            }
            
            Divider()
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .analyticsScreen(name: "\(LogView.self)", extraParameters: ["test4": "test4 value"])
        .onAppear {
            // Initialize data when the view appears
            if let loadedData: [String: Int] = loadDecodedData(forKey: "exerciseSelections") {
                exerciseSelections = loadedData
            }
            
            Task {
                await dbManager.fetchExercises(muscleGroup: "Triceps")
            }
            
        }

    }
}

#Preview {
    ExerciseView()
}
