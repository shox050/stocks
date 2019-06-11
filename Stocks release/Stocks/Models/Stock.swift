//
//  Models.swift
//  Stocks
//
//  Created by shox on 11.09.2018.
//  Copyright © 2018 VladimirYakutin. All rights reserved.
//

struct Stock: Decodable {
    
    let symbol: String
    
    let companyName: String
    
    let price: Double
    
    let priceChange: Double
    
    private enum CodingKeys: String, CodingKey {
        
        case symbol
        
        case companyName
        
        case price = "previousClose"
        
        case priceChange = "change"
    }
}
