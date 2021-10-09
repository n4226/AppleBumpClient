//
//  PersistantStorage.swift
//  OfflineChat
//
//  Created by Michael Baron on 10/3/21.
//

import Foundation


@propertyWrapper
public struct PersistantStorage<T: Codable> {
    private let key: String
    
    public init(key: String, defaultValue: T) {
        self.key = key
        
        // Read value from UserDefaults
        guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
            // Return defaultValue when no data in UserDefaults
            storedValue = defaultValue
            return
        }
        
        // Convert data to the desire data type
        let value = try? JSONDecoder().decode(T.self, from: data)
        storedValue = value ?? defaultValue
    }
    
    private var storedValue: T
    
    public var wrappedValue: T {
        get {
            storedValue
        }
        set {
            storedValue = newValue
            
            // Convert newValue to data
            let data = try? JSONEncoder().encode(newValue)
            
            // Set value to UserDefaults
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
