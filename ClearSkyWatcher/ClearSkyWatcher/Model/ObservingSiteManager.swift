//
//  ObservingSiteManager.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2018-02-12.
//  Copyright © 2018 FoxNet. All rights reserved.
//

import Foundation

class ObservingSiteManager {

    private static let KEYS_URL: URL = URL(string: "https://www.cleardarksky.com/t/chart_keys00.txt")!
    private static let PROPS_URL: URL = URL(string: "https://www.cleardarksky.com/t/chart_prop00.txt")!
    
    lazy var persistenceManager = {
        PersistenceManager.shared
    }()
    
    func populateObservingSites(callbackOn callback: @escaping (Bool) -> Void ) -> Void {
        
        let networkRequestGroup = DispatchGroup()
        var storedResult = Result()
        storedResult.httpCode = Result.HTTP_OK
        
        var observingSiteData = (sortedKeys: [String](), sortedProps: [String]())
        
        DispatchQueue.global(qos: .userInitiated).async {
            networkRequestGroup.enter()
            NetworkHandler.sharedInstance.doRequest(with: ObservingSiteManager.KEYS_URL){ [unowned self] (result) -> Void in
                if result.httpCode == Result.HTTP_OK {
                    observingSiteData.sortedKeys = self.processResponse(rawData: result.responseData)
                } else {
                    logE("Failed to get observing site keys: HTTP:\(result.httpCode) : \(result.responseData)" )
                    storedResult = result
                }
                logD("Leaving Keys Group")
                networkRequestGroup.leave()
            }
        }
        DispatchQueue.global(qos: .userInitiated).async {
            networkRequestGroup.enter()
            NetworkHandler.sharedInstance.doRequest(with: ObservingSiteManager.PROPS_URL){ [unowned self] (result) -> Void in
                if result.httpCode == Result.HTTP_OK {
                    observingSiteData.sortedProps = self.processResponse(rawData: result.responseData)
                } else {
                    logE("Failed to get observing site properties: HTTP:\(result.httpCode) : \(result.responseData)" )
                    storedResult = result
                }
                logD("Leaving Props Group")
                networkRequestGroup.leave()
            }
        }
        
        logD("Waiting for network requests..")
        networkRequestGroup.wait()
        logD("Done waiting for network requests..")
        if storedResult.httpCode == Result.HTTP_OK {
            ObservingSite.updateOrCreateSites(withRawData: observingSiteData, callbackOnComplete: callback)
        } else {
            callback(false)
        }
        
    }
    
    private func processResponse(rawData:String) -> [String] {
        let retValues = rawData.components(separatedBy: "\n")
        return retValues.sorted()
    }
    
    func populateForecast(forObservingSiteKey key: String, callbackOn callback: @escaping (Bool) -> Void) {
        let observingSite = persistenceManager.getObservingSite(withKey: key)
        persistenceManager.delete(entities: observingSite?.forecasts.allObjects as! [Forecast])
        NetworkHandler.sharedInstance.doRequest(with: (observingSite?.url!)!) { (result) -> Void in
            if result.httpCode == Result.HTTP_OK {
                let forecastData = ForecastParser.parse(rawData: result.responseData)
                
                self.persistenceManager.doAsync(block: { (context) in
                    
                    observingSite?.lastUpdatedDate = Date()
                    observingSite?.utcOffset = forecastData.utcOffset
                    observingSite?.lpUpper = forecastData.lpRating.upperBound
                    observingSite?.lpLower = forecastData.lpRating.lowerBound
                    
                    for forecastInfo in forecastData.forecasts {
                        let newForecast = Forecast(context: context)
                        newForecast.belongsTo = observingSite
                        newForecast.cloud = Int32(forecastInfo.cloudCover)
                        newForecast.forecastDate = forecastInfo.date as NSDate
                        newForecast.humidity = Int32(forecastInfo.humidity)
                        newForecast.limitingMagnitudesTrans = forecastInfo.limitingMagnitudes as NSObject
                        newForecast.lunarAltitude = forecastInfo.lunarAltitude
                        newForecast.seeing = Int32(forecastInfo.seeing)
                        newForecast.solarAltitude = forecastInfo.solarAltitude
                        newForecast.temperature = Int32(forecastInfo.temperature)
                        newForecast.wind = Int32(forecastInfo.wind)
                        newForecast.transparency = Int32(forecastInfo.transparency)
                        
                    }
                }, callbackWhenComplete: callback)
            }
        }
    }
}
