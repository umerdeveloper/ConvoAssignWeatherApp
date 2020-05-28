//
//  Alert+Controller.swift
//  ConvoAssignWeatherApp
//
//  Created by Umer Khan on 28/05/2020.
//  Copyright © 2020 Umer Khan. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func alertToUser(title: String, message: String, actionTitle: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action          = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
