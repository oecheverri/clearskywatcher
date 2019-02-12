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
    private let persistenceManager = PersistenceManager.shared
    
    private var isStarted = false
    
    
    private var shouldSeedRegions: Bool {
        return !SettingsManager.shared.haveRegionsBeenSeeded
    }
    
    private var shouldUpdateDatabase: Bool {
        return Date().timeIntervalSince(SettingsManager.shared.databaseLastUpdate) > ClearSkyWatcher.OneDayAsSeconds
    }
    
    private init() {}
    
    func start(callingWhenReady notifyReady: @escaping ((Bool)->Void)) {
//        if shouldSeedRegions {
//            observingSiteManager.seedRegions()
//            SettingsManager.shared.regionsHaveBeenSeeded()
//        }
        
        if shouldUpdateDatabase {
            observingSiteManager.populateObservingSites {
                precondition($0, "Failed to initialize ObservingSiteManager")
                SettingsManager.shared.databaseUpdated()
                self.isStarted = $0
                notifyReady($0)
            }
        } else {
            notifyReady(true)
        }
    }
    
    func getRegions() -> [Region] {
        return persistenceManager.getAllRegions()
    }
    
    func getCountries() -> [String] {
        return persistenceManager.getCountries()
    }
    
    func getRegions(inCountry country: String) -> [Region] {
        return persistenceManager.getRegions(inCountry: country)
    }
    
}
