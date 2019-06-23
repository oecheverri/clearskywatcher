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
        startModel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearSkyWatcherStarted(successfully success: Bool) -> Void {
        
        if success {
            DispatchQueue.main.async(execute: {[unowned self]() in
                self.performSegue(withIdentifier: "Launch", sender: nil)
            })
        } else {
            logE("Failed to start model")
            let alert = UIAlertController(title: "Error", message: "There was an error populating the database, check your internet connection", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: {[unowned self](UIAlertAction) in
                self.startModel()
            } ))
            
        }
    }
    
    func startModel() -> Void {
        logD("Starting ClearSkyWatcher")
        let dispatchQueue = DispatchQueue.global(qos: .userInteractive)
        dispatchQueue.async(execute: {[unowned self]() in
            ClearSkyWatcher.instance.start(callingWhenReady: self.clearSkyWatcherStarted)
        })
    }
}
