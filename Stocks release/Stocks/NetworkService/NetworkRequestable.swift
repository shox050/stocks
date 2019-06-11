//
//  NetworkRequestable.swift
//  Stocks
//
//  Created by shox on 11.09.2018.
//  Copyright © 2018 VladimirYakutin. All rights reserved.
//

import UIKit

protocol NetworkRequestable: class {
    
    func getCompaniesList<T>(responseType: T.Type, completion: @escaping (RequestResult<[T], RequestError>) -> Void)
    where T : Decodable
    
    func getCompanyLogo<T>(by symbol: String,
                           responseType: T.Type,
                           completion: @escaping (RequestResult<T, RequestError>) -> Void)
    where T : Decodable
    
    func getCompanyInfo<T>(by symbol: String,
                           responseType: T.Type,
                           completion: @escaping (RequestResult<T, RequestError>) -> Void)
    where T : Decodable
    
    func getLogo(by symbol: String, completion: @escaping (Data?) -> Void)
    
}
