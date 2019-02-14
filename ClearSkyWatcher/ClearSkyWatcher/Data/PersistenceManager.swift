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
                logE("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    lazy var uiContext = {
        return persistentContainer.viewContext
    }()
    
    lazy var context: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = uiContext
        
        return context
    }()
    
    func getObservingSites(inRegion region: Region) -> [ObservingSite] {
        let observingSiteFetchRequest: NSFetchRequest<ObservingSite> = ObservingSite.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        observingSiteFetchRequest.sortDescriptors = [sortDescriptor]
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
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        observingSiteFetchRequest.sortDescriptors = [sortDescriptor]
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
    
    func getAllRegions() -> [Region] {
        return getRegions()
    }
    
    private func doFetch<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>) -> [T] {
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            logE(error.localizedDescription)
            return [T]()
        }
    }
    
    func doAsync(block: @escaping (NSManagedObjectContext) -> Void, callbackWhenComplete complete: ((Bool) -> Void)? ) {
        context.perform {
            block(self.context)
            do {
                try self.context.save()
                self.uiContext.performAndWait {
                    do {
                        try self.uiContext.save()
                        if complete != nil {
                            complete!(true)
                        }
                    } catch {
                        logE("Error occured saving parebt context: \(error.localizedDescription)")
                        if complete != nil {
                            complete!(false)
                        }
                    }
                }
            } catch {
                logE("Error occured saving private context: \(error.localizedDescription)")
                if complete != nil {
                    complete!(false)
                }
            }
            
        }
    }
    
    func createManagedObjects<T>(usingBlock creationBlock:(NSManagedObjectContext) -> T?) -> T? {
        var object: T?
        context.performAndWait {
            object = creationBlock(context)
            do {
                try context.save()
                uiContext.performAndWait {
                    do {
                        try uiContext.save()
                    } catch {
                        logE("Error occured saving parebt context: \(error.localizedDescription)")
                    }
                }
            } catch {
                logE("Error occured saving private context: \(error.localizedDescription)")
            }
            
        }
        return object
    }
    
    func getFavouriteObservingSites() -> [ObservingSite]{
        
        let fetchRequest: ObservingSite.FetchRequest = ObservingSite.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isFavourite=%@", true)
        
        return doFetch(fetchRequest: fetchRequest)
        
        
    }
    
    func getRegions(inCountry: String? = nil) -> [Region]{
        let regionFetchRequest: Region.FetchRequest = Region.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        regionFetchRequest.sortDescriptors = [sortDescriptor]
        if let country = inCountry {
            let countryPredicate = NSPredicate(format: "country=%@", country)
            regionFetchRequest.predicate = countryPredicate
        }
        let results = doFetch(fetchRequest: regionFetchRequest)
        return results
    }
    
    func getCountries() -> [String] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Region")
        
        fetchRequest.propertiesToFetch = ["country"]
        fetchRequest.propertiesToGroupBy = ["country"]
        fetchRequest.resultType = .dictionaryResultType
        
        do {
            let context = Thread.isMainThread ? self.uiContext : self.context
            let result: [NSDictionary] = try context.fetch(fetchRequest) as! [NSDictionary]
            
            var countries = [String]()
            
            for dictionary in result {
                countries.append(dictionary.allValues[0] as! String)
            }
            return countries
        } catch {
            logE(error.localizedDescription)
        }
        return [String]()
    }
    
    func delete(entities: [NSManagedObject]) {
        context.perform {
            for entity in entities {
                self.context.delete(entity)
            }
            do {
                try self.context.save()
            } catch {
                logE(error.localizedDescription)
            }
        }
    }
    func delete(entity: NSManagedObject) {
        context.perform {
            self.context.delete(entity)
            do {
                try self.context.save()
            } catch {
                logE(error.localizedDescription)
            }
        }
    }
}
