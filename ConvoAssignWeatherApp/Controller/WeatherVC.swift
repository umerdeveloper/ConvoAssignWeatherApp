//
//  WeatherVC.swift
//  ConvoAssignWeatherApp
//
//  Created by Umer Khan on 22/05/2020.
//  Copyright © 2020 Umer Khan. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class WeatherVC: UITableViewController {
    
    var isFirstLaunch           = false
    var tempArray               = [List]()
    var weatherStatusArray      = [Weather]()
    
    let locationManager         = CLLocationManager()
    
    let activityIndicatorView   = UIView()
    
    lazy var activityIndicator  = UIActivityIndicatorView()
    
    lazy var fetchedResultsController = NSFetchedResultsController<WeatherEntity>()
    
    
    
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
        configureActivityIndicatorView()
        configureActivityIndicator()
        initializeFetchResultsController()
        checkFirstLaunchOfApp()
    }
    
    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFirstLaunch {
            return tempArray.count
            
        } else {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let weatherCell     = tableView.dequeueReusableCell(withIdentifier: WeatherCell.weatherCellIdentifier, for: indexPath) as! WeatherCell
        
        if isFirstLaunch {
            
            let celsius         = convertKelvinIntoCelsius(temp: tempArray[indexPath.row].main!.temp)
            let weatherIcon     = weatherStatusArray[indexPath.row].icon
            
            weatherCell.weatherIconView.image = UIImage(named: weatherIcon)
            weatherCell.weatherDescLabel.text = weatherStatusArray[indexPath.row].description
            weatherCell.tempLabel.text        = "\(celsius)℃"
            weatherCell.dateLabel.text        = tempArray[indexPath.row].dateText
            
        } else {
            
            let weatherData = fetchedResultsController.object(at: indexPath)
            
            let tempInCelsius     = convertKelvinIntoCelsius(temp: weatherData.tempInKelvin)
            let weatherIcon       = weatherData.weatherIconName!
            
            weatherCell.weatherIconView.image   = UIImage(named: weatherIcon)
            weatherCell.weatherDescLabel.text   = weatherData.weatherDesc
            weatherCell.tempLabel.text          = "\(tempInCelsius)℃"
            weatherCell.dateLabel.text          = weatherData.dateString
        }
        
        return weatherCell
    }
    
    // MARK:- TableView Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(70)
    }
    
    // MARK:- Configure ActivityIndicator
    private func configureActivityIndicatorView() {
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.backgroundColor    = UIColor(white: 0, alpha: 0.1)
        activityIndicatorView.layer.cornerRadius = 8
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive  = true
    }
    
    
    private func configureActivityIndicator() {
        
        activityIndicatorView.addSubview(activityIndicator)
        
        activityIndicator.style              = .gray
        activityIndicator.color              = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorView.centerYAnchor).isActive = true
    }
    
    // MARK:- Networking
    fileprivate func prepareURLWithCoordinates(latitude: String, longitude: String) {
        
        // TODO:- Make URL Components
        var urlComponents        = URLComponents()
        urlComponents.scheme     = "https"
        urlComponents.host       = NetworkingService.shared.hostURL
        urlComponents.path       = "/data/2.5/forecast"
        urlComponents.queryItems = [
            URLQueryItem(name: "lat", value: latitude),
            URLQueryItem(name: "lon", value: longitude),
            URLQueryItem(name: "appid", value: NetworkingService.shared.apiKey)
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
                }
                catch {
                    print("Unable to fetch JSON Data...")
                }
                
                self?.persistDataFromJSONIntoLocalDB()
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.stopActiviyIndicator()
                }
                
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    // MARK:- CoreData
    func persistDataFromJSONIntoLocalDB() {
        
        let sharedPersistence = PersistenceService.shared
        
        let weatherEntity  = NSEntityDescription.entity(forEntityName: sharedPersistence.entityName, in: sharedPersistence.context)

        guard !tempArray.isEmpty && !weatherStatusArray.isEmpty else { return }
        guard tempArray.count == weatherStatusArray.count       else { return }
        
        for index in 0..<tempArray.count {
            
            let weather = NSManagedObject(entity: weatherEntity!, insertInto: sharedPersistence.context)
            
            weather.setValue(weatherStatusArray[index].icon,        forKey: sharedPersistence.iconKey)
            weather.setValue(weatherStatusArray[index].description, forKey: sharedPersistence.weatherDescKey)
            weather.setValue(tempArray[index].main?.temp,           forKey: sharedPersistence.tempKey)
            weather.setValue(tempArray[index].dateText,             forKey: sharedPersistence.dateKey)
        }
        
        do {
            
            try PersistenceService.shared.context.save()
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // MARK:- Helper Methods
    private func registerTabelViewCell() {
        tableView.register(WeatherCell.self, forCellReuseIdentifier: WeatherCell.weatherCellIdentifier)
    }
    
    
    private func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    private func convertKelvinIntoCelsius(temp kelvin: Double) -> Int {
        Int(kelvin - 273.15)
    }
    
    
    private func stopActiviyIndicator() {
        
        activityIndicatorView.removeFromSuperview()
        activityIndicator.stopAnimating()
    }
    
    private func checkFirstLaunchOfApp() {
        
        if UserDefaults.standard.bool(forKey: "firstLaunched") == true {
            // Not first Launch
            isFirstLaunch = false
            
            DispatchQueue.main.async {
                self.stopActiviyIndicator()
            }
            
            UserDefaults.standard.set(true, forKey: "firstLaunched")
        }
        else {
            // First Launch
            isFirstLaunch = true
            
            UserDefaults.standard.set(true, forKey: "firstLaunched")
        }
    }
}

// MARK:- LocationManagerDelegate
extension WeatherVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        DispatchQueue.main.async {
            self.stopActiviyIndicator()
        }
        
        self.alertToUser(title: "Location", message: "Please Enable your location for current weather forecast.", actionTitle: "Dismiss")
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

// MARK:- CoreDataFetch Delegate
extension WeatherVC: NSFetchedResultsControllerDelegate {
    
    fileprivate func initializeFetchResultsController() {
        
        let request     = NSFetchRequest<WeatherEntity>(entityName: PersistenceService.shared.entityName)
        let sortByDate  = NSSortDescriptor(key: PersistenceService.shared.dateKey, ascending: true)
        
        request.sortDescriptors = [sortByDate]
        
        let context = PersistenceService.shared.context
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
}
