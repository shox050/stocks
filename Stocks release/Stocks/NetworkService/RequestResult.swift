//
//  RequestResult.swift
//  Stocks
//
//  Created by shox on 11.09.2018.
//  Copyright © 2018 VladimirYakutin. All rights reserved.
//

enum RequestResult<T, U> where U: Error {
    
    case success(T)
    
    case failure(U)
}
