//
//  Forecast+CoreDataProperties.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-08.
//  Copyright © 2019 FoxNet. All rights reserved.
//
//

import Foundation
import CoreData


extension Forecast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Forecast> {
        return NSFetchRequest<Forecast>(entityName: "Forecast")
    }

    @NSManaged public var cloud: Int16
    @NSManaged public var darkness: Int16
    @NSManaged public var date: NSDate
    @NSManaged public var humidity: Int16
    @NSManaged public var limitingMagnitude: Double
    @NSManaged public var lunarAltitude: Double
    @NSManaged public var seeing: Int16
    @NSManaged public var solarAltitude: Double
    @NSManaged public var transparency: Int16
    @NSManaged public var wind: Int16
    @NSManaged public var belongsTo: ObservingSite?

}
