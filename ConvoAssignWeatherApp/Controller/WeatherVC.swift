//
//  WeatherVC.swift
//  ConvoAssignWeatherApp
//
//  Created by Umer Khan on 22/05/2020.
//  Copyright © 2020 Umer Khan. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherVC: UITableViewController {
    
    let weatherCellID: String   = "weahterCell"
    let hostURL: String         = "api.openweathermap.org"
    private let apiKey: String  = "e4bf45ce4eb3ab6e86e8ba2ccede2e4f"
    let locationManager         = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerTabelViewCell()
        updateUserLocation()
        
    }
    
    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weatherCell = tableView.dequeueReusableCell(withIdentifier: weatherCellID, for: indexPath) as! WeatherCell
        
        weatherCell.tempLabel.text = "\(22)℃"
        weatherCell.weatherStatusLabel.text = "Overcast Clouds"
        return weatherCell
    }
    
    
    // MARK:- TableView Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    // MARK:- Networking
    fileprivate func fetchWeatherData(with hostURL: String, latitude: String, longitude: String, apiKey: String) {
        
        var urlComponents        = URLComponents()
        urlComponents.scheme     = "https"
        urlComponents.host       = hostURL
        urlComponents.path       = "/data/2.5/forecast"
        urlComponents.queryItems = [
            URLQueryItem(name: "lat", value: latitude),
            URLQueryItem(name: "lon", value: longitude),
            URLQueryItem(name: "appid", value: apiKey)
        ]
       
        guard let url = urlComponents.url else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
           
            guard let data = data else { return }
            
            do {
                let decodedJSON = try JSONDecoder().decode(WeatherCodableStruct.self, from: data)
                

            } catch {
                print("Unable to fetch JSON Data...")
            }
        }
        task.resume()
    }
    
    // MARK:- Helper Methods
    private func registerTabelViewCell() {
        tableView.register(WeatherCell.self, forCellReuseIdentifier: weatherCellID)
    }
    
    private func updateUserLocation() {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func convertKelvinIntoCelsius(temp kelvin: Double) -> Int {
        Int(kelvin - 273.15)
    }
}

extension WeatherVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        let alertController = UIAlertController(title: "Alert", message: "Location Unavailable", preferredStyle: .alert)
        let action          = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(action)
        present(alertController, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        
        // Negative Value means invalid Coordinates
        if location.horizontalAccuracy > 0 {
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let latitude    = String(location.coordinate.latitude)
            let longitude   = String(location.coordinate.longitude)
            
            fetchWeatherData(with: hostURL, latitude: latitude, longitude: longitude, apiKey: apiKey)
        }
    }
}
