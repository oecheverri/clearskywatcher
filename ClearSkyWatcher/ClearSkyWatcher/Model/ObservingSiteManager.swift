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
    
    private static let KEYS_URL: URL = URL(string: "https://www.cleardarksky.com/t/chart_keys00.txt")!
    private static let PROPS_URL: URL = URL(string: "https://www.cleardarksky.com/t/chart_prop00.txt")!
    
    
    var observingSiteIndices : [Character] {
        
        if observingSites != nil {
            var indexSet: Set<Character> = []
            for observingSite in observingSites! {
                let observingSiteName = observingSite.value.getName();
                indexSet.insert(observingSiteName[observingSiteName.startIndex])
            }
            return indexSet.sorted()
        }
        return []
    }
    
    var observingSiteCount: Int {
        if observingSites != nil {
            return observingSites!.count
        } else {
            return 0
        }
    }
    
    private var observingSites: [String : ObservingSite]? = nil
    private(set) var regions: Set<String> = []

    func requestObservingSiteKeys(callbackOn callback: @escaping ([String]?) -> Void ) {
        if observingSites != nil {
            callback(observingSites?.keys.sorted())
        } else {
            populateObservingSites() {
                if $0 {
                    self.requestObservingSiteKeys(callbackOn: callback)
                } else {
                    logE(message: "Failed to populate observing sites.")
                }
            }
        }
    }
    
    func requestObservingSite(withKey key: String, callbackOn callback: @escaping (ObservingSite?) -> Void ) -> Void {
        if observingSites != nil {
            callback(observingSites![key])
        } else {
            populateObservingSites() {
                if $0 {
                    self.requestObservingSite(withKey: key, callbackOn: callback)
                } else {
                    logE(message: "Failed to populate observing sites.")
                }
            }
        }
    }
    
    func populateObservingSites(callbackOn callback: @escaping (Bool) -> Void ) -> Void {
        NetworkHandler.sharedInstance.doRequest(with: ObservingSiteManager.KEYS_URL){ [unowned self] (result) -> Void in
            if result.httpCode == Result.HTTP_OK {
                var observingSiteData = (sortedKeys: [String](), sortedProps: [String]())
                observingSiteData.sortedKeys = self.processResponse(rawData: result.responseData)
                NetworkHandler.sharedInstance.doRequest(with: ObservingSiteManager.PROPS_URL){ [unowned self] (result) -> Void in
                    if result.httpCode == Result.HTTP_OK {
                        observingSiteData.sortedProps = self.processResponse(rawData: result.responseData)
                        self.observingSites = [String : ObservingSite]()
                        for index in 0..<observingSiteData.sortedKeys.count {
                            let currentKeyString = observingSiteData.sortedKeys[index]
                            let currentPropString = observingSiteData.sortedProps[index]
                            if currentKeyString.isEmpty || currentPropString.isEmpty {
                                continue
                            }
                            let currentObservingSite: ObservingSite = ObservingSite(keyString: observingSiteData.sortedKeys[index], propsString: observingSiteData.sortedProps[index])
                            self.observingSites![currentObservingSite.getKey()] = currentObservingSite
                            self.regions.insert(currentObservingSite.getRegion())
                        }
                        callback(true)
                    } else {
                        logE(message: "Failed to get observing site properties: HTTP:\(result.httpCode) : \(result.responseData)" )
                        callback(false)
                    }
                }
            } else {
                logE(message: "Failed to get observing site keys: HTTP:\(result.httpCode) : \(result.responseData)" )
                callback(false)
            }
        }
    }
    
    private func processResponse(rawData:String) -> [String] {
        
        let retValues = rawData.components(separatedBy: "\n")
        let sortedRetValues = retValues.sorted()
        return sortedRetValues
    }
}

