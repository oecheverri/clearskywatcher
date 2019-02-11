//
//  SettingsManager.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-07.
//  Copyright © 2019 FoxNet. All rights reserved.
//
import Foundation

class SettingsManager {
    
    static let shared = SettingsManager()
    
    let defaults = UserDefaults.standard
    
    var databaseLastUpdate: Date {
        let lastUpdate = defaults.object(forKey: "dbLastUpdated") as? Date
        if lastUpdate != nil {
            return lastUpdate!
        } else {
            return Date.distantPast
        }
    }
    
    func databaseUpdated() -> Void {
        defaults.set(Date(), forKey: "dbLastUpdated")
    }
    
    private init() {
    }
}

