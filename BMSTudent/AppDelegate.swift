import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase
import RealmSwift
import UserNotifications

let placeWokabularyArray : [String: Place] = ["GZ" : places.placeGZ, "ULK" : places.placeULK, "ESM" : places.placeESM, "IZM" : places.placeIZM, "SK" : places.placeSK, "OB" : places.placeOB, "RKT" : places.placeRKT, "LESTEX" : places.placeLESTEX, "AS" : places.placeAS, "REAIM" : places.placeREAIM, "TC" : places.placeTC, "Home" : places.placeHome, "Mail" : places.placeMail]

let placeArray : [Place] = [places.placeGZ, places.placeULK, places.placeESM, places.placeIZM, places.placeSK, places.placeOB, places.placeRKT, places.placeLESTEX, places.placeAS, places.placeREAIM, places.placeTC, places.placeHome, places.placeMail]

extension Notification.Name {
    public static let DtoV1TNotificationKey = Notification.Name(rawValue: "DtoV1T")
}

extension Notification.Name {
    public static let DtoV1ZNotificationKey = Notification.Name(rawValue: "DtoV1Z")
}

extension Notification.Name {
    public static let  setGroupNotificationKey = Notification.Name(rawValue: "DtoV3G")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let notificationCenter = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()
    var mytimer = Timer()
    var mytimer2 = Timer()
    
    let myrealm = try! Realm()
    var realmArray: Results<placeDatabase>!
    var realmGroupArray: Results<groupDatabase>!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let options : UNAuthorizationOptions = [.alert , .sound, .badge]
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        
        realmArray = myrealm.objects(placeDatabase.self)
        realmGroupArray = myrealm.objects(groupDatabase.self)
        
        if placeArray.count != realmArray.count {
            for _ in 0...placeArray.count - realmArray.count - 1 {
                let createRealm = placeDatabase(value: ["time": 0])
                try! myrealm.write {
                    myrealm.add(createRealm)
                }
            }
        }
        
        for i in 0...placeArray.count - 1 {
            placeArray[i].time = realmArray[i].time
        }
        
        if realmGroupArray.count < 1 {
            let createRealm = groupDatabase(value: ["yourGroup": "ИУ5-25"])
            try! myrealm.write {
                myrealm.add(createRealm)
            }
        }
        
        FirebaseApp.configure()

        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        let destinationLocation = places.placeGZ.coordinate
        
        mytimer.invalidate()
        
        for place in placeArray {
            if (place.region.contains(locationManager.location?.coordinate ?? destinationLocation)){
                print(place.locationName," OK")
                let myViewController = self.window?.rootViewController as? ViewController
                
                //Добавление информации в твое уведомление
                let userInfo = [ "place" : place]
                let content = UNMutableNotificationContent()
                content.title = "Вы вошли в полигон"
                content.body = place.title ?? "Главное здание"
                content.sound = UNNotificationSound.default
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: "enterPoligon", content: content, trigger: trigger)
                notificationCenter.add(request, withCompletionHandler: nil)
                
                mytimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {
                    _ in place.time = place.time + 1
                    myViewController?.inPolygon = true
                    NotificationCenter.default.post(name: .DtoV1TNotificationKey, object: nil, userInfo: userInfo)
                    myViewController?.setTimeLabel(region: place)
                })
            } else {
                let myViewController = self.window?.rootViewController as? ViewController
                myViewController?.sourceLocation = locationManager.location?.coordinate ?? places.placeIZM.coordinate
                
                mytimer2 = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {
                    _ in
                    myViewController?.inPolygon = false
                    myViewController?.setDestinationLocation()
                })
            }
        }
    
        let myViewController = self.window?.rootViewController as? ViewController
        mytimer2 = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {
            _ in
            myViewController?.inPolygon = false
             myViewController?.setDestinationLocation()
        })
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        mytimer2.invalidate()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        let myViewController = self.window?.rootViewController as? ViewController
        myViewController?.sourceLocation = locationManager.location?.coordinate ?? places.placeIZM.coordinate
        mytimer2 = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {
            _ in
            myViewController?.inPolygon = false
            myViewController?.setDestinationLocation()
        })
    }

    func applicationWillTerminate(_ application: UIApplication) {
        realmArray = myrealm.objects(placeDatabase.self)
        print("Terminate = ", realmArray.count)
        for i in 0...realmArray.count - 1 {
            let currentRealm = realmArray[i]
            try! myrealm.write {
                currentRealm.time = placeArray[i].time
            }
        }
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "openShedule" {
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad : UITabBarController = mainStoryboardIpad.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
            initialViewControlleripad.selectedIndex = 1
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialViewControlleripad
            self.window?.makeKeyAndVisible()
            print("dkjfhsdklghklsdhfkdsjfksdjfksdjfkdsj")
        }
        
        if shortcutItem.type == "openStatistics" {
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad : UITabBarController = mainStoryboardIpad.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
            initialViewControlleripad.selectedIndex = 2
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialViewControlleripad
            self.window?.makeKeyAndVisible()
        }
        
        if shortcutItem.type == "changeGroup" {
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad : UITabBarController = mainStoryboardIpad.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
            initialViewControlleripad.selectedIndex = 2
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialViewControlleripad
            self.window?.makeKeyAndVisible()
            NotificationCenter.default.post(name: .setGroupNotificationKey, object: nil, userInfo: nil)
        }
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    //Когда пользователь выходит из какого-то региона
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            let myViewController = self.window?.rootViewController as? ViewController
            myViewController?.sourceLocation = (locationManager.location?.coordinate)!
            NotificationCenter.default.post(name: .DtoV1ZNotificationKey, object: nil, userInfo: nil)
            myViewController?.setTimeZero()
    
            
            mytimer.invalidate()
            mytimer2 = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {
                _ in
                myViewController?.inPolygon = false
                myViewController?.setDestinationLocation()
            })
            
            myViewController?.setDestinationLocation()
            myViewController?.locationStatusLabel.text = "Таймер"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
       
        if region is CLCircularRegion {
            let myViewController = self.window?.rootViewController as? ViewController
            let userInfo = [ "place" : placeWokabularyArray[region.identifier]]
            myViewController?.sourceLocation = locationManager.location?.coordinate ?? places.placeIZM.coordinate
            
            //myViewController!.mapView.removeOverlays(myViewController!.mapView.overlays)
            mytimer2.invalidate()
            mytimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {
                _ in placeWokabularyArray[region.identifier]?.time = placeWokabularyArray[region.identifier]!.time + 1
                myViewController?.inPolygon = true
                NotificationCenter.default.post(name: .DtoV1TNotificationKey, object: nil, userInfo: userInfo)
                myViewController?.setDestinationLocation()
                
            })
            myViewController?.setDestinationLocation()
            let content = UNMutableNotificationContent()
            content.title = "Вы вошли в полигон"
            content.body = placeWokabularyArray[region.identifier]?.title ?? "Главное здание"
            content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "enterPoligon", content: content, trigger: trigger)
            notificationCenter.add(request, withCompletionHandler: nil)
        }
    }
}
