//
//  UserDataFunctions.swift
//  HealthHomies
//
//  Created by Andrew Collins on 3/13/24.
//

import Foundation

func saveData(_ data: Any, forKey key: String) {
    UserDefaults.standard.set(data, forKey: key)
}

func saveEncodedData<T: Encodable>(_ data: T, forKey key: String) {
    do {
        let dataEncoded = try PropertyListEncoder().encode(data)
        UserDefaults.standard.set(dataEncoded, forKey: key)
    } catch {
        print("Error encoding data: \(error)")
    }
}

func loadInt(forKey key: String) -> Int {
    return UserDefaults.standard.integer(forKey: key)
}

func loadString(forKey key: String) -> String? {
    return UserDefaults.standard.string(forKey: key)
}

func loadDecodedData<T: Decodable>(forKey key: String) -> T? {
    if let dataEncoded = UserDefaults.standard.data(forKey: key) {
        do {
            let decodedData = try PropertyListDecoder().decode(T.self, from: dataEncoded)
            return decodedData
        } catch {
            print("Error decoding data: \(error)")
        }
    } else {
        print("No data found in UserDefaults")
    }
    return nil
}
