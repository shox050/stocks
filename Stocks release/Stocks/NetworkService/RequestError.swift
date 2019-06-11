//
//  RequestError.swift
//  Stocks
//
//  Created by shox on 11.09.2018.
//  Copyright © 2018 VladimirYakutin. All rights reserved.
//

enum RequestError: Error {
    
    case requestFailed
    
    case responseUnsuccessful
    
    case notConnected
    
    case jsonParsingFailure
    
    var localizedDescription: String {
        
        switch self {
        case .notConnected:
            return "Not connected to internet"
        case .requestFailed:
            return "Request failed"
        case .responseUnsuccessful:
            return "Response Unsuccessful"
        case .jsonParsingFailure:
            return "JSON parsing failure"
        }
    }
}
