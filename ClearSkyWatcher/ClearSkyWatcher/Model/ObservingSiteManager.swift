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
    
    func populateForecast(forObservingSiteKey key: String, callbackOn: @escaping (Bool) -> Void) {
        let observingSite = persistenceManager.getObservingSite(withKey: key)
        NetworkHandler.sharedInstance.doRequest(with: (observingSite?.url!)!) { (result) -> Void in
            if result.httpCode == Result.HTTP_OK {
                let parasedForecast = ForecastParser.parse(rawData: result.responseData)
                
                
            
            }
            
        }
        
    }
    

//    func seedRegions() {
//        Region.generateRegions()
//    }
}

