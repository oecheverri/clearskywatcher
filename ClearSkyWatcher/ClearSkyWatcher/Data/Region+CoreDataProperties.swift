//
//  Region+CoreDataProperties.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-06.
//  Copyright © 2019 FoxNet. All rights reserved.
//
//

import Foundation
import CoreData


extension Region {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Region> {
        return NSFetchRequest<Region>(entityName: "Region")
    }

    @NSManaged public var country: String?
    @NSManaged public var name: String?
    @NSManaged public var observingSites: NSSet?

}

// MARK: Generated accessors for observingSites
extension Region {

    @objc(addObservingSitesObject:)
    @NSManaged public func addToObservingSites(_ value: ObservingSite)

    @objc(removeObservingSitesObject:)
    @NSManaged public func removeFromObservingSites(_ value: ObservingSite)

    @objc(addObservingSites:)
    @NSManaged public func addToObservingSites(_ values: NSSet)

    @objc(removeObservingSites:)
    @NSManaged public func removeFromObservingSites(_ values: NSSet)

}
