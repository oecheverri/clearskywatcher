//
//  ForecastTokenizer.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-07.
//  Copyright © 2019 FoxNet. All rights reserved.
//

import Foundation

struct ForecastParser {
    
    typealias ForecastBlob = (date:Date, cloudCover: Int, transparency: Int, seeing: Int, wind:Int, humidity:Int, temperature: Int, limitingMagnitudes: [Double], solarAltitude: Double, lunarAltitude: Double)
    typealias DarknessSegment = (date:Date, limitingMagnitude: Double, solarAltitude: Double, lunarAltitude: Double)
    
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
            var lowerBound = 17.80
            var upperBound = Double.infinity
            
            if !lpRatingString.contains("<") {
                let valueStrings = String(lpRatingString[lpRatingString.index(after: lpRatingString.firstIndex(of: "\"")!)..<lpRatingString.lastIndex(of: "\"")!]).replacingOccurrences(of: " to ", with: "|").split(separator: "|")
                
                lowerBound = NSString(string: String(valueStrings[0])).doubleValue
                upperBound = NSString(string: String(valueStrings[1])).doubleValue
            }
            return (lowerBound, upperBound)
        }
        logE("LP Rating Not Found")
        return (0.0, 0.0)
        
    }
    
    private static func parse(forecastBlockStrings: [String], darknessBlockStrings: [String], utcOffset: Double) -> [ForecastBlob] {
        typealias ForecasetSegment = (date:Date, cloudCover: Int, transparency:Int, seeing: Int, wind: Int, humidity: Int, temperature:Int)
        
        var forecastBlobs = [ForecastBlob]()
        let darknessSegments = parseDarknessSegments(darknessBlockStrings: darknessBlockStrings, utcOffset: utcOffset)
        
        
        for var currentBlockString in forecastBlockStrings {
            currentBlockString = currentBlockString.replacingOccurrences(of: "\t", with: "")
            let bits = currentBlockString.between(firstIndexOf: "(", lastIndexOf: ")").split(separator: ",")
            let dateString = String(bits[0]).between(firstIndexOf: "\"", lastIndexOf: "\"")
            if let forecastDate = parse(dateString: dateString, utcOffset: utcOffset) {
                var forecast: ForecastBlob
                
                forecast.date = forecastDate
                forecast.cloudCover = Int(bits[1]) ?? -1
                forecast.transparency = Int(bits[2]) ?? -1
                forecast.seeing = Int(bits[3]) ?? -1
                forecast.wind = Int(bits[4]) ?? -1
                forecast.humidity = Int(bits[5]) ?? -1
                forecast.temperature = bits.count == 7 ? Int(bits[6]) ?? -1 : -1
                
                let currentDarknessSegments = darknessSegments.filter {
                    let darknessHour = Calendar.current.component(.hour, from: $0.date)
                    let darknessDay = Calendar.current.component(.day, from: $0.date)
                    
                    let forecastHour = Calendar.current.component(.hour, from: forecastDate)
                    let forecastDay = Calendar.current.component(.day, from: forecastDate)
                    
                    return darknessHour == forecastHour && darknessDay == forecastDay
                }
                
                var magnitudes: [Double] = []
                
                var solarSum: Double = 0
                var lunarSum: Double = 0
                
                for darknessSegment in currentDarknessSegments {
                    magnitudes.append(darknessSegment.limitingMagnitude)
                    solarSum += darknessSegment.solarAltitude
                    lunarSum += darknessSegment.lunarAltitude
                }
                
                forecast.limitingMagnitudes = magnitudes
                forecast.solarAltitude = solarSum / Double(currentDarknessSegments.count)
                forecast.lunarAltitude = lunarSum / Double(currentDarknessSegments.count)
                
                forecastBlobs.append(forecast)
                
            }
        }
        return forecastBlobs
    }
    
    private static func parseDarknessSegments(darknessBlockStrings: [String], utcOffset: Double) -> [DarknessSegment] {
        var darknessSegments: [DarknessSegment] = []
        
        for var currentDarknessBlock in darknessBlockStrings {
            currentDarknessBlock = currentDarknessBlock.replacingOccurrences(of: "\t", with: "")
            let bits = currentDarknessBlock.between(firstIndexOf: "(", lastIndexOf: ")").split(separator: ",")
            let dateString = String(bits[0]).between(firstIndexOf: "\"", lastIndexOf: "\"")
            
            if let darknessDate = parse(dateString: dateString, utcOffset: utcOffset) {
                var currentDarknessSegment: DarknessSegment
                currentDarknessSegment.date = darknessDate
                currentDarknessSegment.limitingMagnitude = Double(bits[1]) ?? Double.infinity
                currentDarknessSegment.solarAltitude = Double(bits[2]) ?? Double.infinity
                currentDarknessSegment.lunarAltitude = Double(bits[3])  ?? Double.infinity
                darknessSegments.append(currentDarknessSegment)
            }
        }
        
        return darknessSegments
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


