//
//  NetworkingService.swift
//  ConvoAssignWeatherApp
//
//  Created by Umer Khan on 24/05/2020.
//  Copyright © 2020 Umer Khan. All rights reserved.
//

import Foundation
class NetworkingService {
    
     let hostURL         = "api.openweathermap.org"
     let apiKey          = "e4bf45ce4eb3ab6e86e8ba2ccede2e4f"
    
    // Singleton
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
