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
    
    static let TwelveHoursAsSeconds: Double = 60 * 60 * 12
    static let OneDayAsSeconds: Double = TwelveHoursAsSeconds * 2
    
    private let observingSiteManager = ObservingSiteManager()
    private let persistenceManager = PersistenceManager.shared
    
    private var isStarted = false

    
    private var shouldUpdateDatabase: Bool {
        return Date().timeIntervalSince(SettingsManager.shared.databaseLastUpdate) > ClearSkyWatcher.OneDayAsSeconds
    }
    
    private init() {}
    
    func start(callingWhenReady notifyReady: @escaping ((Bool)->Void)) {
        
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
        
        var regions = [Region]()
        DispatchQueue.global(qos: .userInteractive).sync {
            regions = persistenceManager.getRegions(inCountry: country)
        }
        return regions
        
        
    }
    
    func requestForecast(forSite site: ObservingSite, callbackOn callback: @escaping ([Forecast]) -> Void){
        if site.lastUpdatedDate == nil || Date().timeIntervalSince(site.lastUpdatedDate!) > ClearSkyWatcher.TwelveHoursAsSeconds {
            observingSiteManager.populateForecast(forObservingSiteKey: site.key, callbackOn: { success in
                callback( success ? site.forecasts.sorted(by: {($0 as! Forecast).date! < ($1 as! Forecast).date!}) as! [Forecast] : [Forecast]())
            } )
        } else {
            callback(site.forecasts.sorted(by: {($0 as! Forecast).date! < ($1 as! Forecast).date!}) as! [Forecast])
        }
    }
    
}
