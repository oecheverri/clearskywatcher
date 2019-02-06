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
    
    class func findOrCreate(withName name: String, inContext context: NSManagedObjectContext) -> Region {
        let result = PersistenceManager.shared.getRegion(withName: name)
        
        if result != nil {
            return result!
        } else {
            
            let newRegion = Region(context: context)
            newRegion.name = name
            newRegion.country = countryForRegion(withName: name)
            
            return newRegion
            
        }
        
    }
    
    class func countryForRegion(withName name: String) -> String {
        if canadianRegions.contains(name) {
            return "Canada"
        } else if usRegions.contains(name) {
            return "USA"
        } else if mexicanRegions.contains(name){
            return "Mexico"
        } else if bahamanRegions.contains(name){
            return "Bahamas"
        } else if name == "Cayman Islands" {
            return name
        } else {
            return "Unknown"
        }
    }
    
    private static let canadianRegions = ["Ontario", "Quebec", "Alberta", "Saskatchewan", "British Columbia",
                          "Prince Edward Island", "Newfoundland", "Nova Scotia", "New Brunswick",
                          "Manitoba", "Nunavut", "Yukon", "Northwest Territories"]
    
    private static let usRegions = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "DC", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
    
    private static let mexicanRegions = ["Baja California", "Chihuahua", "Sonora"]
    private static let bahamanRegions = ["Cat Island", "Grand Bahama", "New Providence"]
    
}
