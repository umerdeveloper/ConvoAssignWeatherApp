//
//  WeatherCell.swift
//  ConvoAssignWeatherApp
//
//  Created by Umer Khan on 22/05/2020.
//  Copyright © 2020 Umer Khan. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {
    
    static let weatherCellIdentifier  = "weahterCell"

    
    // MARK:- UI Components
    let containerView        = UIView()
    let weatherIconView      = UIImageView()
    let weatherDescLabel     = UILabel()
    let tempLabel            = UILabel()
    let dateLabel            = UILabel()
    
    
    // MARK:- Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureContainerView()
        configureWeatherIconView()
        configureWeatherDescLabel()
        configureTempLabel()
        configureDateLabel()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Configure UI Components
    
    private func configureContainerView() {
                
        addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive            = true
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive    = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive  = true
        
        containerView.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }

    // MARK:- Weatehr Icon
    private func configureWeatherIconView() {
                
        containerView.addSubview(weatherIconView)
        
        weatherIconView.contentMode = .scaleAspectFill

        weatherIconView.translatesAutoresizingMaskIntoConstraints    = false
        weatherIconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive            = true
        weatherIconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive    = true
        
        weatherIconView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        weatherIconView.widthAnchor.constraint(equalToConstant: 64).isActive  = true
    }
    
    // MARK:- Weahter Description Label
    private func configureWeatherDescLabel() {
        
        containerView.addSubview(weatherDescLabel)
        weatherDescLabel.sizeToFit()
        weatherDescLabel.textAlignment  = .center
        weatherDescLabel.font           = .systemFont(ofSize: 12, weight: .light)
        
        weatherDescLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherDescLabel.topAnchor.constraint(equalTo: weatherIconView.bottomAnchor, constant: 2).isActive      = true
        weatherDescLabel.centerXAnchor.constraint(equalTo: weatherIconView.centerXAnchor).isActive = true
    }
    
    // MARK:- Temperature Label
    private func configureTempLabel() {
       
        containerView.addSubview(tempLabel)
        
        tempLabel.sizeToFit()
        tempLabel.textAlignment     = .right
        tempLabel.font              = .systemFont(ofSize: 30, weight: .medium)
        tempLabel.textColor         = UIColor(white: 0, alpha: 0.5)
                    
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        tempLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive             = true
        tempLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive  = true

        tempLabel.widthAnchor.constraint(equalToConstant: 80).isActive  = true
        tempLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    // MARK:- Date Label
    private func configureDateLabel() {
        
        containerView.addSubview(dateLabel)
        
        dateLabel.sizeToFit()
        dateLabel.textAlignment = .right
        dateLabel.font          = .systemFont(ofSize: 12, weight: .light)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 2).isActive              = true
        dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
    }
}
