//
//  Forecast+CoreDataClass.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-05.
//  Copyright © 2019 FoxNet. All rights reserved.
//
//

import Foundation
import CoreData


public class Forecast: NSManagedObject {
    
    lazy var date: Date? = {
        return forecastDate as Date?
    }()

}
