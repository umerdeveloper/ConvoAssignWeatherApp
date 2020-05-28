//
//  AppDelegate.swift
//  ConvoAssignWeatherApp
//
//  Created by Umer Khan on 22/05/2020.
//  Copyright © 2020 Umer Khan. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print(NSHomeDirectory())
        return true
    }
}

