//
//  ClearSkyWatcher.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-04.
//  Copyright © 2019 FoxNet. All rights reserved.
//

import Foundation

class ClearSkyWatcher {
    
    static var instance: ClearSkyWatcher = ClearSkyWatcher()
    
    private var observingSiteManager = ObservingSiteManager()
    
    private init() {}
    
    func start(callingWhenReady notifyReady: @escaping ((Bool)->Void)) {
//        observingSiteManager.populateObservingSites() {
//            precondition($0, "Failed to initialize ObservingSiteManager")
//            notifyReady($0)
//        }
        
        notifyReady(true)
    }
    
    
}
