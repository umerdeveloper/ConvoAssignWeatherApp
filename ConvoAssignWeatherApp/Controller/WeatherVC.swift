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
    
    var temperatureArray        = [List]()
    var weatherStatusArray      = [Weather]()
    
    let locationManager         = CLLocationManager()
    
    let activityIndicatorView   = UIView()
    lazy var activityIndicator  = UIActivityIndicatorView()
    
    lazy var fetchedResultsController = NSFetchedResultsController<WeatherEntity>()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show until new data is not fetched from server
        if temperatureArray.isEmpty {
            activityIndicator.startAnimating()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerTabelViewCell()
        setupLocationManager()
        configureActivityIndicatorView()
        configureActivityIndicator()
        checkFirstLaunchOfApp()
        initializeFetchResultsController()
    }
    
    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFirstLaunch {
            return temperatureArray.count
            
        } else {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let weatherCell     = tableView.dequeueReusableCell(withIdentifier: WeatherCell.weatherCellIdentifier, for: indexPath) as! WeatherCell
        
        // From Server
        if isFirstLaunch {
            
            let celsius         = convertKelvinIntoCelsius(temp: temperatureArray[indexPath.row].main!.temp)
            let weatherIcon     = weatherStatusArray[indexPath.row].icon
            
            weatherCell.weatherIconView.image = UIImage(named: weatherIcon)
            weatherCell.weatherDescLabel.text = weatherStatusArray[indexPath.row].description
            weatherCell.tempLabel.text        = "\(celsius)℃"
            weatherCell.dateLabel.text        = temperatureArray[indexPath.row].dateText
            
        }
        
        // From LocalDB with latest Fetched from Server, sync with Server
        else {
            
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
    fileprivate func configureActivityIndicatorView() {
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.backgroundColor    = UIColor(white: 0, alpha: 0.1)
        activityIndicatorView.layer.cornerRadius = 8
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive  = true
    }
    
    
    fileprivate func configureActivityIndicator() {
        
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
                    
                    // list use for Temperature
                    if let lists = decodedJSON.list {
                        self?.temperatureArray.append(contentsOf: lists)
                        
                        // this is for Icon and WeatherDesc
                        for list in lists {
                            self?.weatherStatusArray.append(contentsOf: list.weather!)
                        }
                    }
                }
                catch let error {
                    print("Unable to fetch JSON Data, Error: \(error.localizedDescription)")
                }
                
                self?.persistWeatherDataFromJSONIntoLocalDB()
                
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
    func persistWeatherDataFromJSONIntoLocalDB() {
        
        if isFirstLaunch {
            persistWeatherDataIntoLocalDB()
            
        } else if !isFirstLaunch && isNewDataFetchedFromServer() {
            
            // Old Data
            removeWeatherDataFromLocalDB()
            
            // New Data
            persistWeatherDataIntoLocalDB()
        }
    }
    
     func persistWeatherDataIntoLocalDB() {
        
        let sharedPersistence = PersistenceService.shared
        
        let weatherEntity  = NSEntityDescription.entity(forEntityName: sharedPersistence.entityName, in: sharedPersistence.context)

        guard !temperatureArray.isEmpty && !weatherStatusArray.isEmpty else { return }
        guard temperatureArray.count == weatherStatusArray.count       else { return }
        
        // always 40 items
        for index in 0..<temperatureArray.count {
            
            let weather = NSManagedObject(entity: weatherEntity!, insertInto: sharedPersistence.context)
            
            weather.setValue(weatherStatusArray[index].icon,         forKey: sharedPersistence.iconKey)
            weather.setValue(weatherStatusArray[index].description,  forKey: sharedPersistence.weatherDescKey)
            weather.setValue(temperatureArray[index].main?.temp,     forKey: sharedPersistence.tempKey)
            weather.setValue(temperatureArray[index].dateText,       forKey: sharedPersistence.dateKey)
        }
        
        do {
            try sharedPersistence.context.save()
        }
        catch let error {
            print("Could not save. \(error), \(error.localizedDescription)")
        }
    }
    
     private func removeWeatherDataFromLocalDB() {
        
        let context             = PersistenceService.shared.context
        let fetchRequest        = NSFetchRequest<NSFetchRequestResult>(entityName: PersistenceService.shared.entityName)
        
        // why bacth request, because it removes without loading data into Memory
        let batchDeleteRequest  = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            
        } catch let error {
            print("Unable to remove data error: \(error.localizedDescription)")
            return
        }
    }
    
    func isNewDataFetchedFromServer() -> Bool {
        
        // check data appended into array from server
        guard !temperatureArray.isEmpty else { fatalError() }
        
        let context        = PersistenceService.shared.context
        let fetchRequest   = NSFetchRequest<NSFetchRequestResult>(entityName: PersistenceService.shared.entityName)
        
        // sort as always fetched from Server
        let sortByDate               = NSSortDescriptor(key: PersistenceService.shared.dateKey, ascending: true)
        fetchRequest.sortDescriptors = [sortByDate]
        
        // helper properties
        var dateArray      = [String]()
        var hasSomeChanges = false
        
        do {
            let weatherData = try context.fetch(fetchRequest)
            
            for data in weatherData as! [NSManagedObject] {
                
                let date = data.value(forKey: PersistenceService.shared.dateKey)
                dateArray.append(date as! String)
            }
            
        } catch let error {
            print("Unable to read from LocalDB, Error: \(error.localizedDescription)")
        }
        
        // Number of items returned from JSON always 40
        for index in 0..<40 {
           
            // sorted DateString is in dateArray
            if dateArray[index] == temperatureArray[index].dateText {
                hasSomeChanges = false
                
            } else {
                hasSomeChanges = true
            }
        }
        return hasSomeChanges
    }
    
    // MARK:- Helper Methods
    private func registerTabelViewCell() {
        tableView.register(WeatherCell.self, forCellReuseIdentifier: WeatherCell.weatherCellIdentifier)
    }
    
    
    func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func convertKelvinIntoCelsius(temp kelvin: Double) -> Int {
        Int(kelvin - 273.15)
    }
    
    
    private func stopActiviyIndicator() {
        
        activityIndicatorView.removeFromSuperview()
        activityIndicator.stopAnimating()
    }
    
    func checkFirstLaunchOfApp() {
        
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
            
            // coordinates only get once, not multiple times
            locationManager.delegate = nil
            
            let latitude    = String(location.coordinate.latitude)
            let longitude   = String(location.coordinate.longitude)
            
            prepareURLWithCoordinates(latitude: latitude, longitude: longitude)
        }
    }
}

// MARK:- CoreDataFetch Delegate
extension WeatherVC: NSFetchedResultsControllerDelegate {
    
    // TODO:- Prepare FetchedResultsController
    fileprivate func initializeFetchResultsController() {
        
        let request     = NSFetchRequest<WeatherEntity>(entityName: PersistenceService.shared.entityName)
        let sortByDate  = NSSortDescriptor(key: PersistenceService.shared.dateKey, ascending: true)
        
        // sort, show FIFO style means from current day
        request.sortDescriptors = [sortByDate]
        
        let context = PersistenceService.shared.context
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error.localizedDescription)")
        }
    }
}
