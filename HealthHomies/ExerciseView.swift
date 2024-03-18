//
//  ExerciseView.swift
//  HealthHomies
//
//  Created by Andrew Collins on 3/17/24.
//

import SwiftUI

struct ExerciseReps: Hashable, Encodable, Decodable {
    let reps: Int
    let goal: Int
    
    // Implementing hash(into:) method
    func hash(into hasher: inout Hasher) {
        hasher.combine(reps)
    }

    // Implementing == method to compare two Food structs
    static func == (lhs: ExerciseReps, rhs: ExerciseReps) -> Bool {
        return lhs.reps == rhs.reps
    }
}

struct ExerciseView: View {
    @State private var waterIntake = 0
    @State private var selectedMuscleGroup: String = ""
    @State private var selectedExercise: String = ""
    @State private var selectedRepAmount: Int = 0
    @State private var selectedSetAmount: Int = 0
    @State private var exerciseSelections = [String: ExerciseReps]()
    @EnvironmentObject var manager: HealthManager
    @StateObject var dbManager = FirestoreManager()
    
    @State private var exerciseReps: [Int] = [1, 10]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                VStack(alignment: .leading) {
                    
                    Text("Muscle Group")
                        .bold()
                    if !dbManager.fetchedMuscleGroups.isEmpty {
                        Picker("Muscle Group", selection: $selectedMuscleGroup) {
                            ForEach(dbManager.fetchedMuscleGroups.sorted(), id: \.self) { muscleGroup in
                                Text(muscleGroup)
                                    .tag(muscleGroup)
                                    .frame(alignment: .leading)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, maxHeight: 48, alignment: .leading) // Ensure the picker fills the width
                        .task {
                            selectedMuscleGroup = dbManager.fetchedMuscleGroups.sorted()[0]
                        }
                        .onChange(of: selectedMuscleGroup) {
                            if let selectedMuscleGroup = dbManager.fetchedMuscleGroups.sorted().first(where: { $0 == selectedMuscleGroup }) {
                                Task {
                                    await dbManager.fetchExercises(muscleGroup: selectedMuscleGroup)
                                    
                                    selectedExercise = dbManager.fetchedExercises[0].name
                                    
                                    if let selectedExercise = dbManager.fetchedExercises.first(where: { $0.name == selectedExercise }) {

                                        exerciseReps = [
                                            1,
                                            selectedExercise.repetitions,
                                        ]

                                        selectedRepAmount = exerciseReps[1]
                                        
                                        selectedSetAmount = selectedExercise.sets

                                    }
                                        
                                }

                                
                                
                            }
                        }
                    }
                    
                    Divider() // Add a divider for separation
                    
                    Text("Exercise")
                        .bold()
                    if !dbManager.fetchedExercises.isEmpty {
                        Picker("Exercise", selection: $selectedExercise) {
                            ForEach(dbManager.fetchedExercises, id: \.id) { exercise in
                                Text(exercise.name)
                                    .tag(exercise.name)
                                    .frame(alignment: .leading)
                                    .font(.headline)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, maxHeight: 54, alignment: .leading) // Ensure the picker fills the width
                        .task {
                            selectedExercise = dbManager.fetchedExercises[0].name
                        }
                        .onChange(of: selectedExercise) {
                            if let selectedExercise = dbManager.fetchedExercises.first(where: { $0.name == selectedExercise }) {
                                exerciseReps = [
                                    1,
                                    selectedExercise.repetitions,
                                ]

                                selectedRepAmount = exerciseReps[1]
                                
                                selectedSetAmount = selectedExercise.sets

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
                
                VStack {
                    List {
                        Section(header: Text("Recommended")) {
                            Text("Sets: \(selectedSetAmount)")
                                .font(.subheadline)
                            Text("Reps: \(exerciseReps[1])")
                                .font(.subheadline)
                            Text("Total: \(selectedSetAmount * exerciseReps[1])")
                                .font(.title3)
                        }
                        .font(.caption)
                    }
                    .frame(height: 190)
                    .padding(.bottom)
                    
                    Button(action: {
                        if selectedExercise != "" {
                            let reps = selectedRepAmount + (exerciseSelections[selectedExercise]?.reps ?? 0)
                            exerciseSelections[selectedExercise] = ExerciseReps(reps: reps, goal: exerciseSelections[selectedExercise]?.goal ?? selectedSetAmount * exerciseReps[1])
                            saveEncodedData(exerciseSelections, forKey: "exerciseSelections")
                            manager.updateOverallScore()
                            // TODO: update the cards with relevant info + include in recommendation
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
                    
                }
                .padding(.vertical)
            }
            
            
            
            Divider()
            
            List {
                Section(header: Text("Logged Exercise and Repetitions")) {
                    ForEach(exerciseSelections.sorted(by: { $0.key < $1.key }), id: \.key) { exercise, reps in
                        Text("\(exercise): \(reps.reps) / \(reps.goal)")
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
            if let loadedData: [String: ExerciseReps] = loadDecodedData(forKey: "exerciseSelections") {
                exerciseSelections = loadedData
            }
            
            Task {
                await dbManager.fetchMuscleGroups()
            }
            
        }

    }
}

#Preview {
    ExerciseView()
}
