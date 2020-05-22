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
    
    let weatherCellID: String = "weahterCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        registerTabelViewCell()
    }
    
    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weatherCell = tableView.dequeueReusableCell(withIdentifier: weatherCellID, for: indexPath) as! WeatherCell
        
        weatherCell.tempLabel.text = "\(22)°"
        weatherCell.weatherStatusLabel.text = "Overcast Clouds"
        return weatherCell
    }
    
    
    // MARK:- TableView Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    
    // MARK:- Helper Methods
    private func registerTabelViewCell() {
        tableView.register(WeatherCell.self, forCellReuseIdentifier: weatherCellID)
    }
}

extension WeatherVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
}
