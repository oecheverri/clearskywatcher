//
//  Forecast+CoreDataProperties.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-13.
//  Copyright © 2019 FoxNet. All rights reserved.
//
//

import Foundation
import CoreData


extension Forecast {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Forecast> {
        return NSFetchRequest<Forecast>(entityName: "Forecast")
    }

    @NSManaged public var cloud: Int32
    @NSManaged public var forecastDate: NSDate?
    @NSManaged public var humidity: Int32
    @NSManaged public var limitingMagnitude: Double
    @NSManaged public var lunarAltitude: Double
    @NSManaged public var seeing: Int32
    @NSManaged public var solarAltitude: Double
    @NSManaged public var transparency: Int32
    @NSManaged public var wind: Int32
    @NSManaged public var temperature: Int32
    @NSManaged public var belongsTo: ObservingSite?

}
