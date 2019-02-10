//
//  ObservingSite+CoreDataClass.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-05.
//  Copyright © 2019 FoxNet. All rights reserved.
//
//
import CoreData


public class ObservingSite: NSManagedObject {
    
    typealias FetchRequest = NSFetchRequest<ObservingSite>
    
    var url: URL? {
        return URL(string: "https://www.cleardarksky.com/txtc/\(key!)csp.txt")
    }
    
    var regionName: String {
        if let region = containingRegion {
            return region.name
        } else {
            return ""
        }
    }
    
    class func updateOrCreate(withKeyString keyString: String, withPropertyString propertyString: String, callbackOnComplete callback: ((Bool) -> Void)?) {
        
        PersistenceManager.shared.doAsync(block: { context in
            
            let observingSiteData = parse(keyString: keyString, propString: propertyString)
            let existingSite = PersistenceManager.shared.getObservingSite(withKey: observingSiteData.key)
            
            let site = existingSite ?? ObservingSite(context: context)
            
            site.key = observingSiteData.key
            site.name = observingSiteData.name
            site.latitude = observingSiteData.latitude ?? Float.infinity
            site.longitude = observingSiteData.longitude ?? Float.infinity
            
            let containingRegion = Region.findOrCreate(withName: observingSiteData.regionName)
            site.containingRegion = containingRegion
        }, callbackWhenComplete: callback)
        
        
    }
    
    
    private class func parse(keyString: String, propString: String) -> (key: String, name: String, latitude: Float?, longitude: Float?, regionName: String) {
        var retTuple: (key: String, name: String, latitude: Float?, longitude: Float?, regionName: String)
        
        let keyArray = keyString.split(separator: "|")
        let propArray = propString.split(separator: "|")
        
        retTuple.key = String(keyArray[0])
        retTuple.regionName = String(keyArray[1])
        
        if keyArray.count >= 4 {
            retTuple.latitude = NSString(string: String(keyArray[2])).floatValue
            retTuple.longitude = NSString(string: String(keyArray[3])).floatValue
        } else {
            retTuple.latitude = nil
            retTuple.longitude = nil
        }
        retTuple.name = String(propArray[2])
        
        return retTuple
    }

}
