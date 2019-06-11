//
//  Endpoint.swift
//  Stocks
//
//  Created by shox on 11.09.2018.
//  Copyright © 2018 VladimirYakutin. All rights reserved.
//

import Foundation
import Alamofire

enum Endpoint: URLRequestConvertible {
    
    static let baseUrl = "https://api.iextrading.com/1.0/stock"
    
    case companiesList
    case companyInfo(companySymbol: String)
    case companyLogo(companySymbol: String)
    
    var path: String {
        switch self {
        case .companyInfo(let companySymbol):
            return "\(companySymbol)/quote"
        case .companiesList:
            return "market/list/infocus"
        case .companyLogo(let companySymbol):
            return "\(companySymbol)/logo"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        
        let baseUrl = try Endpoint.baseUrl.asURL()
        let url = baseUrl.appendingPathComponent(path)
                
        return URLRequest(url: url)
    }
}
