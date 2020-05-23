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
    let weatherStatusLabel   = UILabel()
    
    
    // MARK:- Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSelectedRowBGColor()
        configureContainerView()
        configureTempLabel()
        configureWeatherStatusLabel()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Configure UI Components
    
    private func configureSelectedRowBGColor() {
       let bgView = UIView()
        bgView.backgroundColor      = UIColor(white: 0, alpha: 0.01)
        self.selectedBackgroundView = bgView
    }
    
    private func configureContainerView() {
        
        addSubview(containerView)
        containerView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive            = true
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive    = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive  = true
    }
    
    
    private func configureTempLabel() {
        
        containerView.addSubview(tempLabel)
        tempLabel.font = .systemFont(ofSize: 35, weight: .medium)
                    
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tempLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive             = true
        tempLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive  = true
        tempLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive      = true
    }

    
    private func configureWeatherStatusLabel() {
        
        containerView.addSubview(weatherStatusLabel)
        weatherStatusLabel.font = .systemFont(ofSize: 30, weight: .medium)
        
        weatherStatusLabel.adjustsFontSizeToFitWidth                    = true
        weatherStatusLabel.translatesAutoresizingMaskIntoConstraints    = false
        
        weatherStatusLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive            = true
        weatherStatusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive    = true
        weatherStatusLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive     = true
        
        weatherStatusLabel.trailingAnchor.constraint(equalTo: tempLabel.leadingAnchor, constant: -20).isActive = true
    }
}
