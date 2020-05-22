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
    
    
    
    
    
    
    
    
    // MARK:- Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureContainerView()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Configure UI Components
    
    private func configureContainerView() {
        
        addSubview(containerView)
        containerView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive            = true
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive    = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive  = true
    }
}
