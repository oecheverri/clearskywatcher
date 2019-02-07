//
//  ClearSkyWatcher.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-04.
//  Copyright © 2019 FoxNet. All rights reserved.
//

import Foundation

class ClearSkyWatcher {
    
    static let instance: ClearSkyWatcher = ClearSkyWatcher()
    static let OneDayAsSeconds: Double = 60 * 60 * 24
    static let TwelveHoursAsSeconds: Double = 60 * 60 * 12
    
    private let observingSiteManager = ObservingSiteManager()
    
    
    private var shouldUpdateDatabase: Bool {
        return Date().timeIntervalSince(SettingsManager.shared.databaseLastUpdate) > ClearSkyWatcher.OneDayAsSeconds
    }
    
    private init() {}
    
    func start(callingWhenReady notifyReady: @escaping ((Bool)->Void)) {
        if shouldUpdateDatabase {
            observingSiteManager.populateObservingSites() {
                precondition($0, "Failed to initialize ObservingSiteManager")
                SettingsManager.shared.databaseUpdated()
                notifyReady($0)
            }
        } else {
            notifyReady(true)
        }
    }
    
}
