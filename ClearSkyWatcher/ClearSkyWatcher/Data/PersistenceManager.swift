//
//  PersistenceManager.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-05.
//  Copyright © 2019 FoxNet. All rights reserved.
//

import CoreData

class PersistenceManager {
    
    static var shared = PersistenceManager() 
    
    private init() {}
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ClearSkyWatcher")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = {
        return persistentContainer.viewContext
    }()
    
    func save() {        
        if context.hasChanges {
            do {
                try context.save()
                print("Saved successfully!")
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                context.reset()
            }
        }
    }
    
    func getObservingSites(inRegion region: Region) -> [ObservingSite] {
        let observingSiteFetchRequest: NSFetchRequest<ObservingSite> = ObservingSite.fetchRequest()
        observingSiteFetchRequest.predicate = NSPredicate(format: "containingReguin == %@", region)
        
        return doFetch(fetchRequest: observingSiteFetchRequest)
    }
    
    func getObservingSite(withKey key: String) -> ObservingSite? {
        let observingSiteFetchRequest: NSFetchRequest<ObservingSite> = ObservingSite.fetchRequest()
        observingSiteFetchRequest.predicate = NSPredicate(format: "key == %@", key)
        
        let results = doFetch(fetchRequest: observingSiteFetchRequest)
        if !results.isEmpty {
            return results[0]
        }
        return nil
    }
    
    func getObservingSites() -> [ObservingSite] {
        let observingSiteFetchRequest: ObservingSite.FetchRequest = ObservingSite.fetchRequest()
        let results = doFetch(fetchRequest: observingSiteFetchRequest)
        
        return results
    }
    
    func getRegion(withName name: String) -> Region? {
        let regionFetchRequest: Region.FetchRequest = Region.fetchRequest()
        regionFetchRequest.predicate = NSPredicate(format: "name == %@", name)
        let results = doFetch(fetchRequest: regionFetchRequest)
        
        if !results.isEmpty {
            return results[0]
        }
        return nil
    }
    
    private func doFetch<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>) -> [T] {
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            print(error)
            return [T]()
        }
    }
}
