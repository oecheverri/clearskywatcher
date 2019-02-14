//
//  ObservingSite+CoreDataClass.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-05.
//  Copyright © 2019 FoxNet. All rights reserved.
//
//
import CoreData
import UIKit

public class ObservingSite: NSManagedObject {
    
    typealias FetchRequest = NSFetchRequest<ObservingSite>
    
    var lastUpdatedDate: Date? {
        get {
            return lastUpdated as Date?
        }
        
        set {
            lastUpdated = newValue as NSDate?
        }
    }
    
    var url: URL? {
        return URL(string: "https://www.cleardarksky.com/txtc/\(key)csp.txt")
    }
    
    var bortleScale: Double {
        if lpUpper >= 21.99 {
            return 1
        } else if lpUpper >= 21.89 {
            return 2
        } else if lpUpper >= 21.69 {
            return 3
        } else if lpUpper >= 21.25 {
            return 4
        } else if lpUpper >= 20.49 {
            return 4.5
        } else if lpUpper >= 19.5 {
            return 5
        } else if lpUpper >= 18.95 {
            return 6
        } else if lpUpper >= 18.38 {
            return 7
        } else if lpUpper >= 17.8 {
            return 8
        } else {
            return 9
        }
    }
    
    var bortleColour: UIColor {
        
        if lpUpper >= 21.99 {
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        } else if lpUpper >= 21.93 {
            return #colorLiteral(red: 0.09410531074, green: 0.09412551671, blue: 0.09410088509, alpha: 1)
        } else if lpUpper >= 21.89 {
            return #colorLiteral(red: 0.1842938662, green: 0.1843264103, blue: 0.1842867732, alpha: 1)
        } else if lpUpper >= 21.81 {
            return #colorLiteral(red: 0.0005297987373, green: 0.07496456057, blue: 0.4870464206, alpha: 1)
        } else if lpUpper >= 21.69 {
            return #colorLiteral(red: 0, green: 0.1417003274, blue: 0.9111667275, alpha: 1)
        } else if lpUpper >= 21.51 {
            return #colorLiteral(red: 0.2067156434, green: 0.4757850766, blue: 0.07131318003, alpha: 1)
        } else if lpUpper >= 21.25 {
            return #colorLiteral(red: 0.3872820139, green: 0.8710254431, blue: 0.1434858739, alpha: 1)
        } else if lpUpper >= 20.91 {
            return #colorLiteral(red: 0.6603723168, green: 0.6467352509, blue: 0.1208710298, alpha: 1)
        } else if lpUpper >= 20.49 {
            return #colorLiteral(red: 0.9193202853, green: 0.9030746818, blue: 0.1630668342, alpha: 1)
        } else if lpUpper >= 20.02 {
            return #colorLiteral(red: 0.7309498787, green: 0.3672432303, blue: 0.08000934869, alpha: 1)
        } else if lpUpper >= 19.5 {
            return #colorLiteral(red: 0.8522849083, green: 0.4311630428, blue: 0.09574414045, alpha: 1)
        } else if lpUpper >= 18.95 {
            return #colorLiteral(red: 0.6083537936, green: 0.1229484752, blue: 0.05112357438, alpha: 1)
        } else if lpUpper >= 18.38 {
            return #colorLiteral(red: 0.8640343547, green: 0.1743722856, blue: 0.07599133998, alpha: 1)
        } else if lpUpper >= 17.8 {
            return #colorLiteral(red: 0.6538819671, green: 0.6590919495, blue: 0.6545040011, alpha: 1)
        } else {
            return #colorLiteral(red: 0.9881489873, green: 0.9882904887, blue: 0.9881179929, alpha: 1)
        }
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
