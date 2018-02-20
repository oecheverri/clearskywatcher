//
//  ObservingSiteManager.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2018-02-12.
//  Copyright © 2018 FoxNet. All rights reserved.
//

import Foundation

class ObservingSiteManager {
    
    static var instance: ObservingSiteManager = ObservingSiteManager()
    
    private static let KEYS_URL: URL = URL(string: "https://cleardarksky.com/t/chart_keys00.txt")!
    private static let PROPS_URL: URL = URL(string: "https://cleardarksky.com/t/chart_prop00.txt")!
    
    private var mObservingSites: [String : ObservingSite]? = nil
    private var mRegions: Set<String> = Set<String>()

    func getObservingSite(key: String, callback: (ObservingSite?) -> Void ) -> Void {
        if mObservingSites != nil {
            callback(mObservingSites![key])
        } else {
            populateObservingSites() { (success) -> Void in
                if success {
                    getObservingSite(key: key, callback: callback)
                } else {
                    logE(message: "Failed to populate observing sites.")
                }
            }
        }
    }
    
    func getRegions() -> Set<String> {
        return mRegions
    }
    
    private func populateObservingSites(completionHandler: (Bool) -> Void ) -> Void {
        var sortedKeys: [String] = [String]()
        var sortedProps: [String] = [String]()
        NetworkHandler.sharedInstance.doRequest(url: ObservingSiteManager.KEYS_URL){(result) -> Void in
            if result.httpCode == Result.HTTP_OK {
                sortedKeys = self.processResponse(rawData: result.responseData)
                NetworkHandler.sharedInstance.doRequest(url: ObservingSiteManager.KEYS_URL){(result) -> Void in
                    if result.httpCode == Result.HTTP_OK {
                        sortedProps = self.processResponse(rawData: result.responseData)
                        self.mObservingSites = [String : ObservingSite]()
                        for index in 0...sortedKeys.count - 1 {
                            let currentObservingSite: ObservingSite = ObservingSite(keyString: sortedKeys[index], propsString: sortedProps[index])
                            self.mObservingSites![currentObservingSite.getKey()] = currentObservingSite
                            self.mRegions.insert(currentObservingSite.getRegion())
                        }
                    } else {
                        logE(message: "Failed to get observing site properties: HTTP:\(result.httpCode) : \(result.responseData)" )
                    }
                }
            } else {
                logE(message: "Failed to get observing site keys: HTTP:\(result.httpCode) : \(result.responseData)" )
            }
        }
    }
    
    private func processResponse(rawData:String) -> [String] {
        var entities = rawData.split(separator: "\n")
        entities = entities.sorted()
        
        var stringEntities: [String] = [String]()
        for entity in entities {
            stringEntities.append(String(entity))
        }
        
        return stringEntities
        
    }
}

