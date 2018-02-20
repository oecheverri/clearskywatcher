//
//  Logger.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2018-02-18.
//  Copyright © 2018 FoxNet. All rights reserved.
//

import Foundation


let LOG_ERROR = 0;
let LOG_WARNING = 1;
let LOG_DEBUG = 2;

fileprivate var LOG_LEVEL = LOG_DEBUG

public func logD(message: String, functionName: String = #function) {
    if LOG_LEVEL == LOG_DEBUG {
        NSLog("D/\(functionName): \(message)")
    }
}

func logW(message: String, functionName: String = #function) {
    if LOG_LEVEL >= LOG_WARNING {
        NSLog("W/\(functionName): \(message)")
    }
}

func logE(message: String, functionName: String = #function) {
    if LOG_LEVEL >= LOG_ERROR {
        NSLog("E/\(functionName): \(message)")
    }
}


