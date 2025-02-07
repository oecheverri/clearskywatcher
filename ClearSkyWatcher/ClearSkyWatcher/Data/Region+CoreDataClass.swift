//
//  Region+CoreDataClass.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-05.
//  Copyright © 2019 FoxNet. All rights reserved.
//
//

import Foundation
import CoreData


public class Region: NSManagedObject {
    
    typealias FetchRequest = NSFetchRequest<Region>
    
    class func findOrCreate(withName name: String) -> Region {
        if let foundRegion = PersistenceManager.shared.getRegion(withName: name) {
            return foundRegion
        } else {
            let createdRegion = PersistenceManager.shared.createManagedObjects { (context: NSManagedObjectContext) -> Region in
                let newRegion = Region(context: context)
                newRegion.name = name
                newRegion.country = GetCountryName(forRegionName: name)
                return newRegion
            }
            return createdRegion!
        }
    }
    
    static func GetCountryName(forRegionName regionName: String) -> String{
        if canadianRegionNames.contains(regionName) {
            return "Canada"
        } else if usRegionNanes.contains(regionName) {
            return "USA"
        } else if mexicanRegionNames.contains(regionName) {
            return "Mexico"
        } else if caribbeanRegionNames.contains(regionName) {
            return "Caribbeans"
        } else {
            return "Unknown"
        }
    }
    
    var observingSitesSorted: [ObservingSite] {
        return observingSites.sortedArray(using: [NSSortDescriptor(key: "name", ascending: true)]) as! [ObservingSite]
    }
    
    private static let canadianRegionNames = ["Ontario", "Quebec", "Alberta", "Saskatchewan", "British Columbia",
                          "Prince Edward Island", "Newfoundland", "Nova Scotia", "New Brunswick",
                          "Manitoba", "Nunavut", "Yukon", "Northwest Territories"]
    
    private static let usRegionNanes = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "DC", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
    
    private static let mexicanRegionNames = ["Baja California", "Chihuahua", "Sonora"]
    private static let caribbeanRegionNames = ["Cat Island", "Grand Bahama", "New Providence", "Cayman Islands"]
    
}
