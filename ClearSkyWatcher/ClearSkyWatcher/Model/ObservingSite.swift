//
//  ObservingSite.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2018-01-26.
//  Copyright © 2018 FoxNet. All rights reserved.
//

import Foundation
class ObservingSite {
    
    private var mKey: String
    private var mRegion: String
    private var mName: String
    private var mLatitude: Float?
    private var mLongitude: Float?
    
    init(keyString: String, propsString: String) {
        let keyProps = keyString.split(separator: "|")
        mKey = String(keyProps[0])
        mRegion = String(keyProps[1])
        
        if keyProps.count >= 4 {
            mLatitude = NSString(string: String(keyProps[2])).floatValue
            mLongitude = NSString(string: String(keyProps[3])).floatValue
        }
        
        let propProps = propsString.split(separator: "|")
        mName = String(propProps[2])
        
    }
    init(key: String, region: String, name: String, latitude: Float?, longitude: Float?) {
        mKey = key
        mRegion = region
        mName = name
        mLatitude = latitude
        mLongitude = longitude
    }
    
    func getURL() -> URL? {
        return URL(string: "https://www.cleardarksky.com/txtc/\(mKey)csp.txt")
    }
    
    func getKey() -> String {
        return mKey
    }
    
    func getRegion() -> String {
        return mRegion
    }
    
    func getName() -> String {
        return mName
    }
    
    func getLatitude() -> Float {
        if let retLatitude = mLatitude {
            return retLatitude
        } else {
            return 0
        }
    }
    
    func getLongitude() -> Float {
        if let retLongitude = mLatitude {
            return retLongitude
        } else {
            return 0
        }
    }

}
