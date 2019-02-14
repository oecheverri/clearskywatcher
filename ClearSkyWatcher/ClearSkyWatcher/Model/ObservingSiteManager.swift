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
        NetworkHandler.sharedInstance.doRequest(with: ObservingSiteManager.KEYS_URL){ [unowned self] (result) -> Void in
            if result.httpCode == Result.HTTP_OK {
                var observingSiteData = (sortedKeys: [String](), sortedProps: [String]())
                observingSiteData.sortedKeys = self.processResponse(rawData: result.responseData)
                NetworkHandler.sharedInstance.doRequest(with: ObservingSiteManager.PROPS_URL){ [unowned self] (result) -> Void in
                    if result.httpCode == Result.HTTP_OK {
                        observingSiteData.sortedProps = self.processResponse(rawData: result.responseData)
                        for index in 0..<observingSiteData.sortedKeys.count {
                            let currentKeyString = observingSiteData.sortedKeys[index]
                            let currentPropString = observingSiteData.sortedProps[index]
                            if currentKeyString.isEmpty || currentPropString.isEmpty {
                                continue
                            }
                            ObservingSite.updateOrCreate(withKeyString: observingSiteData.sortedKeys[index], withPropertyString: observingSiteData.sortedProps[index], callbackOnComplete: index==(observingSiteData.sortedKeys.count-1) ? callback : nil)
                        }
                    } else {
                        logE("Failed to get observing site properties: HTTP:\(result.httpCode) : \(result.responseData)" )
                        callback(false)
                    }
                }
            } else {
                logE("Failed to get observing site keys: HTTP:\(result.httpCode) : \(result.responseData)" )
                callback(false)
            }
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
                        newForecast.limitingMagnitude = forecastInfo.limitingMagnitude
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

