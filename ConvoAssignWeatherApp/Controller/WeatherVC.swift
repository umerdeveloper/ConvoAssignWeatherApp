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
    var tempArray               = [List]()
    var weatherStatusArray      = [Weather]()
    let locationManager         = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        registerTabelViewCell()
        setupLocationManager()
    }
    
    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tempArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let weatherCell     = tableView.dequeueReusableCell(withIdentifier: weatherCellID, for: indexPath) as! WeatherCell
        
        let celsius         = convertKelvinIntoCelsius(temp: tempArray[indexPath.row].main!.temp)
        let weatherIcon   = weatherStatusArray[indexPath.row].icon
        
        weatherCell.weatherIconView.image = UIImage(named: weatherIcon)
        weatherCell.tempLabel.text        = "\(celsius)℃"
        
        return weatherCell
    }
    
    
    // MARK:- TableView Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(70)
    }
    
    // MARK:- Networking
    fileprivate func prepareURLWithCoordinates(latitude: String, longitude: String) {
        
        // TODO:- Make URL Components
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
        
        // TODO:- Pass URL to NetworkService
        fetchWeatherData(with: url)
    }
    
    
    fileprivate func fetchWeatherData(with url: URL) {
        
        NetworkingService.shared.request(url) { (result) in
            switch result {
                case .success(let data):
                do {
                    let decodedJSON = try JSONDecoder().decode(WeatherCodableStruct.self, from: data)
                    if let lists = decodedJSON.list {
                        self.tempArray.append(contentsOf: lists)
                        for list in lists {
                            self.weatherStatusArray.append(contentsOf: list.weather!)
                        }
                    }
                } catch {
                    print("Unable to fetch JSON Data...")
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    // MARK:- Helper Methods
    private func registerTabelViewCell() {
        tableView.register(WeatherCell.self, forCellReuseIdentifier: weatherCellID)
    }
    
    private func setupLocationManager() {
        
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
            
            prepareURLWithCoordinates(latitude: latitude, longitude: longitude)
        }
    }
}
