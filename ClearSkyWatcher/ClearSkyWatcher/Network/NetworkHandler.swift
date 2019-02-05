//
//  NetworkHandle.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2018-01-26.
//  Copyright © 2018 FoxNet. All rights reserved.
//

import Foundation


struct Result {
    
    static let UNKNOWN_ERROR: Int = -1
    static let HTTP_OK = 200
    
    var httpCode: Int = 0;
    var responseData: String = ""
}

class NetworkHandler {
    
    static var sharedInstance:NetworkHandler = NetworkHandler()
    
    func doRequest(with url: URL, callback: ((Result)-> Void)?) {
        
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error)->Void in

            var result = Result()
            
            if let httpResponse = response as? HTTPURLResponse {
                result.httpCode = httpResponse.statusCode
                if httpResponse.statusCode == 200 {
                    result.responseData = self.getString(inData: data)
                } else {
                    result.responseData = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                }
            }
            else
            {
                result.httpCode = Result.UNKNOWN_ERROR
                result.responseData = "Unknown response received."
            }
            
            if callback != nil {
                callback!(result)
            }
        })
        dataTask.resume();
    }

    private func getString(inData data: Data?) -> String {
        if let stringData = data {
            let retString = String.init(data: stringData, encoding: String.Encoding.isoLatin1)
            return retString ?? "";
        }
        return "";
    }
}
