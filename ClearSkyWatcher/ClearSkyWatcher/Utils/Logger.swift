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

public func logI(_ message: String, functionName: String = #function, fileName: String = #file, line: Int = #line) {
    NSLog("ℹ️/\(fileName)(\(line))\(functionName): \(message)")
}

public func logD(_ message: String, functionName: String = #function, fileName: String = #file, line: Int = #line) {
    if LOG_LEVEL == LOG_DEBUG {
        NSLog("🐛/\(fileName)(\(line))\(functionName): \(message)")
    }
}

func logW(_ message: String, functionName: String = #function, fileName: String = #file, line: Int = #line) {
    if LOG_LEVEL >= LOG_WARNING {
        NSLog("⚠️/\(fileName)(\(line))\(functionName): \(message)")
    }
}

func logE(_ message: String, functionName: String = #function, fileName: String = #file, line: Int = #line) {
    if LOG_LEVEL >= LOG_ERROR {
        NSLog("‼️/\(fileName)(\(line))\(functionName): \(message)")
    }
}


