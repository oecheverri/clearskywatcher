//
//  ForecastTokenizer.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-07.
//  Copyright © 2019 FoxNet. All rights reserved.
//

import Foundation

struct ForecastParser {
    
    typealias ForecastBlob = (date:Date, cloudCover: Int, transparency: Int, seeing: Int, wind:Int, humidity:Int, temperature: Int, limitingMagnitude: Double, solarAltitude: Double, lunarAltitude: Double)
    
    private init(){}
    
    static func parse(rawData:String) -> (utcOffset: Double, lpRating: (lowerBound: Double, upperBound: Double), forecasts: [ForecastBlob]) {
        
        var forecastArray = [ForecastBlob]()
        var utcOffset: Double = 0.0
        var lpRating = (0.0, 0.0)
        var forecastBlocks = [String]()
        var darknessBlocks = [String]()
        
        let dataLines = rawData.split(separator: "\n")
        
        for var lineNumber in dataLines.startIndex..<dataLines.endIndex {
            let currentLine = dataLines[lineNumber]
            if currentLine.starts(with: "UTC_offset") {
                utcOffset = parse(utcOffsetString: String(currentLine))
            } else if currentLine.starts(with: "lp_rating_mags_per_square_arcsec") {
                lpRating = parse(lpRatingString: String(currentLine))
            } else if currentLine.starts(with: "blocks") {
                lineNumber+=2
                while case let newCurrentLine = dataLines[lineNumber], newCurrentLine != ")" {
                    forecastBlocks.append(String(newCurrentLine))
                    lineNumber+=1
                }
            } else if currentLine.starts(with: "darkness_blocks"){
                lineNumber+=1
                while case let newCurrentLine = dataLines[lineNumber], newCurrentLine != ")" {
                    darknessBlocks.append(String(newCurrentLine))
                    lineNumber+=1
                }
            }
        }
        
        if !forecastBlocks.isEmpty && !darknessBlocks.isEmpty {
            forecastArray += parse(forecastBlockStrings: forecastBlocks, darknessBlockStrings: darknessBlocks, utcOffset: utcOffset)
        }
        
        return (utcOffset, lpRating, forecastArray)
    }
    
    private static func parse(utcOffsetString: String) -> Double {
        let splitPoint = utcOffsetString.lastIndex(of: "\t")
        if splitPoint != nil {
            let valueString = String(utcOffsetString[splitPoint!..<utcOffsetString.endIndex])
            return NSString(string: valueString).doubleValue
        }
        logE("UTC Offset Not Found")
        return 0.0
    }
    
    private static func parse(lpRatingString: String) -> (lowerBound: Double, upperBound: Double) {
        
        let splitPoint = lpRatingString.lastIndex(of: " ")
        if splitPoint != nil {
            let valueStrings = String(lpRatingString[lpRatingString.index(after: lpRatingString.firstIndex(of: "\"")!)..<lpRatingString.lastIndex(of: "\"")!]).replacingOccurrences(of: " to ", with: "|").split(separator: "|")
            
            let lowerBound = NSString(string: String(valueStrings[0])).doubleValue
            let upperBound = NSString(string: String(valueStrings[1])).doubleValue
            
            return (lowerBound, upperBound)
        }
        logE("LP Rating Not Found")
        return (0.0, 0.0)
        
    }
    
    private static func parse(forecastBlockStrings: [String], darknessBlockStrings: [String], utcOffset: Double) -> [ForecastBlob] {
        typealias ForecastNib = (date:Date, cloudCover: Int, transparency:Int, seeing: Int, wind: Int, humidity: Int, temperature:Int)
        
        var forecastBlobs = [ForecastBlob]()
        var forecastNibs = [Date : ForecastNib]()
        
        for var currentBlockString in forecastBlockStrings {
            currentBlockString = currentBlockString.replacingOccurrences(of: "\t", with: "")
            let bits = currentBlockString.between(firstIndexOf: "(", lastIndexOf: ")").split(separator: ",")
            let dateString = String(bits[0]).between(firstIndexOf: "\"", lastIndexOf: "\"")
            if let forecastDate = parse(dateString: dateString, utcOffset: utcOffset) {
                
                let cloudCover = Int(bits[1]) ?? -1
                let transparency = Int(bits[2]) ?? -1
                let seeing = Int(bits[3]) ?? -1
                let wind = Int(bits[4]) ?? -1
                let humidity = Int(bits[5]) ?? -1
                let temperature = Int(bits[6]) ?? -1
                
                forecastNibs[forecastDate] = (forecastDate, cloudCover, transparency, seeing, wind, humidity, temperature)
            }
        }
        
        for var currentDarknessBlock in darknessBlockStrings {
            currentDarknessBlock = currentDarknessBlock.replacingOccurrences(of: "\t", with: "")
            let bits = currentDarknessBlock.between(firstIndexOf: "(", lastIndexOf: ")").split(separator: ",")
            let dateString = String(bits[0]).between(firstIndexOf: "\"", lastIndexOf: "\"")
            if let darknessDate = parse(dateString: dateString, utcOffset: utcOffset) {
                if let forecastNib = forecastNibs[darknessDate] {
                    let limitingMagnitude = Double(bits[1]) ?? Double.infinity
                    let solarAltitude = Double(bits[2]) ?? Double.infinity
                    let lunaraltitude = Double(bits[3])  ?? Double.infinity
                    
                    forecastBlobs.append((date:forecastNib.date, cloudCover: forecastNib.cloudCover, transparency: forecastNib.transparency, seeing: forecastNib.seeing, wind:forecastNib.wind, humidity:forecastNib.humidity, temperature: forecastNib.temperature, limitingMagnitude: limitingMagnitude, solarAltitude: solarAltitude, lunarAltitude: lunaraltitude))
                }
            }
        }
        
        return forecastBlobs
    }
    
    private static func parse(dateString: String, utcOffset: Double) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: Int(utcOffset * 60 * 60))
        
        let parsedDate = dateFormatter.date(from: dateString)
        
        return parsedDate
    }
}


extension String {
    func between(firstIndexOf start: Character, lastIndexOf end: Character) -> String {
        assert(self.contains(start))
        
        let startIndex = self.index(after: self.firstIndex(of: start)!)
        let endIndex = self.lastIndex(of: end)
        
        assert(endIndex != nil && startIndex <= endIndex!)
        
        return String(self[startIndex..<endIndex!])
    }
}


