//
//  WeatherCell.swift
//  ConvoAssignWeatherApp
//
//  Created by Umer Khan on 22/05/2020.
//  Copyright © 2020 Umer Khan. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {
    
    // MARK:- UI Components
    let containerView        = UIView()
    let tempLabel            = UILabel()
    let weatherIconView      = UIImageView()
    
    
    // MARK:- Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureContainerView()
        configureTempLabel()
        configureWeatherStatusLabel()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Configure UI Components
    
    private func configureContainerView() {
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive            = true
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive    = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive  = true
    }
    
    
    private func configureTempLabel() {
        
        containerView.addSubview(tempLabel)
        tempLabel.font              = .systemFont(ofSize: 30, weight: .medium)
        tempLabel.textAlignment     = .right
        tempLabel.textColor         = UIColor(white: 0, alpha: 0.5)
                    
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tempLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive             = true
        tempLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive  = true
        tempLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive      = true
        tempLabel.widthAnchor.constraint(equalToConstant: 90).isActive = true
    }

    
    private func configureWeatherStatusLabel() {
        
        containerView.addSubview(weatherIconView)
        weatherIconView.contentMode = .scaleAspectFill

        weatherIconView.translatesAutoresizingMaskIntoConstraints    = false
        weatherIconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive            = true
        weatherIconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive    = true
        weatherIconView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive     = true
                
        weatherIconView.widthAnchor.constraint(equalToConstant: 64).isActive = true
    }
}
