//
//  AppDelegate.swift
//  BMSTudent
//
//  Created by Sergei Petrenko on 02/05/2019.
//  Copyright © 2019 Sergei. All rights reserved.
//

import UIKit
import CoreLocation

let allplaces : [String: Place] = ["GZ" : places.placeGZ, "ULK" : places.placeULK, "ESM" : places.placeESM, "IZM" : places.placeIZM, "SK" : places.placeSK, "OB" : places.placeOB, "Home" : places.placeHome]

let places1 : [Place] = [places.placeGZ, places.placeULK, places.placeESM, places.placeIZM, places.placeSK, places.placeOB, places.placeHome]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let locationManager = CLLocationManager()
    var mytimer = Timer()
    var mytimer2 = Timer()
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        let destinationLocation = places.placeGZ.coordinate
        
        mytimer.invalidate()
        
        for place in places1 {
            if (place.region.contains(locationManager.location?.coordinate ?? destinationLocation)){
                print(place.locationName," OK")
                let myViewController = self.window?.rootViewController as? ViewController
                
                mytimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {
                    _ in place.time = place.time + 1
                    myViewController?.inPolygon = true
                    myViewController?.setTimeLabel(region: place)
                    
                })
            } else {
                /*let myViewController = self.window?.rootViewController as? ViewController
                myViewController?.sourceLocation = (locationManager.location?.coordinate)!
                
                mytimer2 = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {
                    _ in
                    myViewController?.inPolygon = false
                    myViewController?.setTravelTime()
                })*/
            }
        }
    
        /*let myViewController = self.window?.rootViewController as? ViewController
        mytimer2 = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {
            _ in
            myViewController?.inPolygon = false
            myViewController?.setTravelTime()
        })*/
        
        return true
    }
   

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print ("background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("выход из background")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
       print("active")
    }

    func applicationWillTerminate(_ application: UIApplication) {
       print("terminate")
    }


}

extension AppDelegate: CLLocationManagerDelegate {
    //Когда пользователь выходит из какого-то региона
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            
            let myViewController = self.window?.rootViewController as? ViewController
            myViewController?.sourceLocation = (locationManager.location?.coordinate)!
            myViewController?.setTimeZero()
            
            mytimer.invalidate()
            
            mytimer2 = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {
                _ in
                myViewController?.inPolygon = false
                myViewController?.setTravelTime()
                
            })
            //Для себя проверка
            print("Exit")
            print(region.identifier)
        }
    }
    
    //Когда пользователь входит в какой-то регион
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
       
        if region is CLCircularRegion {
            let myViewController = self.window?.rootViewController as? ViewController
            myViewController?.sourceLocation = (locationManager.location?.coordinate)!
            myViewController!.mapView.removeOverlays(myViewController!.mapView.overlays)
            mytimer2.invalidate()
            mytimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {
                _ in allplaces[region.identifier]?.time = allplaces[region.identifier]!.time + 1
                myViewController?.inPolygon = true
                myViewController?.setTimeLabel(region: allplaces[region.identifier]!)
                
            })
            
            //Для себя проверка
            print("Enter")
            print(region.identifier)
        }
    }
  
    
}
