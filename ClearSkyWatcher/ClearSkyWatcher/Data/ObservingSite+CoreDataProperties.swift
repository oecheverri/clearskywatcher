//
//  ObservingSite+CoreDataProperties.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-12.
//  Copyright © 2019 FoxNet. All rights reserved.
//
//

import Foundation
import CoreData


extension ObservingSite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ObservingSite> {
        return NSFetchRequest<ObservingSite>(entityName: "ObservingSite")
    }

    @NSManaged public var isFavourite: Bool
    @NSManaged public var key: String
    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
    @NSManaged public var name: String
    @NSManaged public var lastUpdated: NSDate
    @NSManaged public var containingRegion: Region?
    @NSManaged public var forecasts: NSSet

}

// MARK: Generated accessors for forecasts
extension ObservingSite {

    @objc(addForecastsObject:)
    @NSManaged public func addToForecasts(_ value: Forecast)

    @objc(removeForecastsObject:)
    @NSManaged public func removeFromForecasts(_ value: Forecast)

    @objc(addForecasts:)
    @NSManaged public func addToForecasts(_ values: NSSet)

    @objc(removeForecasts:)
    @NSManaged public func removeFromForecasts(_ values: NSSet)

}
