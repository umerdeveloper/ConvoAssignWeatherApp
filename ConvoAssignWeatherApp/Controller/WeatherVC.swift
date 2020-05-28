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
    lazy var activityIndicator  = UIActivityIndicatorView()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if tempArray.isEmpty {
            activityIndicator.startAnimating()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerTabelViewCell()
        setupLocationManager()
        prepareActivityIndicator()
    }
    
    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tempArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let weatherCell     = tableView.dequeueReusableCell(withIdentifier: weatherCellID, for: indexPath) as! WeatherCell
        
        let celsius         = convertKelvinIntoCelsius(temp: tempArray[indexPath.row].main!.temp)
        let weatherIcon     = weatherStatusArray[indexPath.row].icon
        
        weatherCell.weatherIconView.image = UIImage(named: weatherIcon)
        weatherCell.weatherDescLabel.text = weatherStatusArray[indexPath.row].description
        weatherCell.tempLabel.text        = "\(celsius)℃"
        weatherCell.dateLabel.text        = tempArray[indexPath.row].dateText
        
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
        
        NetworkingService.shared.request(url) { [weak self] (result) in
            switch result {
                case .success(let data):
                do {
                    let decodedJSON = try JSONDecoder().decode(WeatherCodableStruct.self, from: data)
                    if let lists = decodedJSON.list {
                        self?.tempArray.append(contentsOf: lists)
                        for list in lists {
                            self?.weatherStatusArray.append(contentsOf: list.weather!)
                        }
                    }
                } catch {
                    print("Unable to fetch JSON Data...")
                }
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.activityIndicator.stopAnimating()
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
    
    
    private func prepareActivityIndicator() {
        
        let position                         = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator                    = UIActivityIndicatorView(frame: position)
        activityIndicator.style              = .gray
        activityIndicator.center             = self.view.center
        activityIndicator.color              = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        activityIndicator.backgroundColor    = UIColor(white: 0, alpha: 0.1)
        activityIndicator.layer.cornerRadius = 8
        
        self.view.addSubview(activityIndicator)
    }
}

extension WeatherVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        activityIndicator.stopAnimating()
        
        let alertController = UIAlertController(title: "Message", message: "Location Unavailable, Please Enable location for weather forecast or check internet connectivity ", preferredStyle: .alert)
        let action          = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        
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
