//
//  WeatherCodableStruct.swift
//  ConvoAssignWeatherApp
//
//  Created by Umer Khan on 23/05/2020.
//  Copyright © 2020 Umer Khan. All rights reserved.
//

import UIKit

// MARK:- MainStruct
struct WeatherCodableStruct: Decodable {
    
    let cod:        String
    let message:    Int
    let cnt:        Int
    let list:       [List]?
    let city:       City?
}

// MARK:- List
struct List: Decodable {
    
    let dt:         Int
    let main:       Main?
    let weather:    [Weather]?
    let clouds:     Clouds?
    let wind:       Wind?
    let rain:       Rain?
    let sys:        Sys?
    let dateText:   String

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, rain, sys
        case dateText = "dt_txt"
    }
}

// MARK:- City
struct City: Codable {
    
    let id: Int
    let name, country:  String
    let coord:  Coord?
    let timezone, sunrise, sunset:   Int
}

// MARK:- Main
struct Main: Codable {
    
    let temp, feelsLike, tempMin, tempMax, tempKf:  Double
    let pressure, seaLevel, grandLevel, humidity:   Int

    enum CodingKeys: String, CodingKey {

        case temp       = "temp"
        case feelsLike  = "feels_like"
        case tempMin    = "temp_min"
        case tempMax    = "temp_max"
        case pressure   = "pressure"
        case seaLevel   = "sea_level"
        case grandLevel = "grnd_level"
        case humidity   = "humidity"
        case tempKf     = "temp_kf"
    }
}

// MARK:- Weather
struct Weather: Codable {
    
    let id:             Int
    let main:           String
    let description:    String
    let icon:           String
}

// MARK:- Clouds
struct Clouds: Codable { let all: Int }

// MARK:- Wind
struct Wind: Codable {
    let speed:  Double
    let deg:    Int
}

// MARK:- Rain
struct Rain: Codable {
    let h3: Double

    enum CodingKeys: String, CodingKey {
        case h3 = "3h"
    }
}

// MARK:- Sys
struct Sys: Codable { let pod: String }

// MARK:- Coord
struct Coord: Codable { let lat, lon: Double }
