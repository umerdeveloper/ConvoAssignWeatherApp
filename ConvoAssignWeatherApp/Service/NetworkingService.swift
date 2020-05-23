//
//  NetworkingService.swift
//  ConvoAssignWeatherApp
//
//  Created by Umer Khan on 24/05/2020.
//  Copyright © 2020 Umer Khan. All rights reserved.
//

import Foundation
class NetworkingService {
    private init() { }
    
    static let shared = NetworkingService()
    
    func request(_ baseURL: URL, completion: @escaping (Result<Data, NSError>) -> Void) {
        
        let task = URLSession.shared.dataTask(with: baseURL) { (data, _, error) in
            
            if let unwrappedError = error {
                completion(.failure(unwrappedError as NSError))
            }
            else if let unwrappedData = data {
                completion(.success(unwrappedData))
            }
        }
        task.resume()
    }
}
