//
//  NetworkService.swift
//  Stocks
//
//  Created by shox on 11.09.2018.
//  Copyright © 2018 VladimirYakutin. All rights reserved.
//

import Foundation
import Alamofire

class NetworkService: NetworkRequestable {
    
    private let executionQueue = DispatchQueue(label: "NetworkServiceQueue", qos: .background, attributes: .concurrent)
    
    func getCompaniesList<T>(responseType: T.Type, completion: @escaping (RequestResult<[T], RequestError>) -> Void)
        where T : Decodable {
            
            request(Endpoint.companiesList) { response in
                
                let jsonDecoder = JSONDecoder()
                
                guard let responseData = response.data else {
                    print("Request returned no data")
                    return
                }
                
                do {
                    let stocks = try jsonDecoder.decode([T].self, from: responseData)
                    
                    completion(.success(stocks))
                } catch let error {
                    
                    print("Failed to decode response with error: \(error)")
                    
                    completion(.failure(RequestError.jsonParsingFailure))
                }
            }
    }
    
    func getCompanyLogo<T>(by symbol: String,
                           responseType: T.Type,
                           completion: @escaping (RequestResult<T, RequestError>) -> Void)
        where T : Decodable {
            
            request(Endpoint.companyLogo(companySymbol: symbol)) { response in
                
                let jsonDecoder = JSONDecoder()
                
                guard let responseData = response.data else {
                    print("Request returned no data")
                    return
                }
                
                do {
                    let response = try jsonDecoder.decode(T.self, from: responseData)
                    completion(.success(response))
                    
                } catch let error {
                    print("Failed to decode response with error: \(error)")
                    
                    completion(.failure(RequestError.jsonParsingFailure))
                }
            }
    }
    
    func getCompanyInfo<T>(by symbol: String,
                           responseType: T.Type,
                           completion: @escaping (RequestResult<T, RequestError>) -> Void)
        where T : Decodable {
            
            request(Endpoint.companyInfo(companySymbol: symbol)) { response in
                
                let jsonDecoder = JSONDecoder()
                
                guard let responseData = response.data else {
                    print("Request returned no data")
                    return
                }
                
                do {
                    let response = try jsonDecoder.decode(T.self, from: responseData)
                    completion(.success(response))
                    
                } catch let error {
                    print("Failed to decode response with error: \(error)")
                    
                    completion(.failure(RequestError.jsonParsingFailure))
                }
            }
    }
    
    func getLogo(by symbol: String, completion: @escaping (Data?) -> Void) {
        request(Endpoint.companyLogo(companySymbol: symbol)) { [weak self] response in
            
            let jsonDecoder = JSONDecoder()
            
            guard let responseData = response.data else {
                print("Request returned no data")
                return
            }
            
            do {
                let logo = try jsonDecoder.decode(Logo.self, from: responseData)
                guard let url = URL(string: logo.url) else {
                    completion(nil)
                    return
                }
                self?.getFile(from: url, completion: completion)
            } catch let error {
                print("Failed to decode response with error: \(error)")
                
                completion(nil)
            }
        }
    }
    
    private func request(_ endpoint: Endpoint, completion: @escaping (DataResponse<Data>) -> Void) {
        Alamofire.request(endpoint)
            .validate()
            .responseData(queue: executionQueue) { response in
                completion(response)
        }
    }
    
    private func getFile(from url: URL, completion: @escaping (Data?) -> Void) {
        
        Alamofire.request(url)
            .validate()
            .responseData(queue: executionQueue) { response in
                completion(response.data)
        }
    }
}








