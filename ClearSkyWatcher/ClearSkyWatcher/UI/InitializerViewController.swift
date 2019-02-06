//
//  SplashScreenController.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-05.
//  Copyright © 2019 FoxNet. All rights reserved.
//
import UIKit

class InitializerViewController: UIViewController {

    lazy var persistenceManager = {
        return PersistenceManager.shared
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ClearSkyWatcher.instance.start(callingWhenReady: clearSkyWatcherStarted)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearSkyWatcherStarted(successfully: Bool) -> Void {
        precondition(successfully)
        
//        DispatchQueue.main.async(execute: {
//            self.performSegue(withIdentifier: "Launch", sender: nil)
//        })

        do {
            let observingSiteRequest: ObservingSite.FetchRequest = ObservingSite.fetchRequest()
            let regionRequest: Region.FetchRequest = Region.fetchRequest()
            
            let observingSiteCount = try persistenceManager.context.count(for: observingSiteRequest)
            
            let regionCount = try persistenceManager.context.count(for: regionRequest)
            
            print("ObservingSites: \(observingSiteCount)")
            print("Regions: \(regionCount)")
            
            
            
        } catch {
            print(error)
        }
    }
    

}
