import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase
import RealmSwift
import UserNotifications

let allplaces : [String: Place] = ["GZ" : places.placeGZ, "ULK" : places.placeULK, "ESM" : places.placeESM, "IZM" : places.placeIZM, "SK" : places.placeSK, "OB" : places.placeOB, "RKT" : places.placeRKT, "LESTEX" : places.placeLESTEX, "AS" : places.placeAS, "REAIM" : places.placeREAIM, "TC" : places.placeTC, "Home" : places.placeHome]

let places1 : [Place] = [places.placeGZ, places.placeULK, places.placeESM, places.placeIZM, places.placeSK, places.placeOB, places.placeRKT, places.placeLESTEX, places.placeAS, places.placeREAIM, places.placeTC, places.placeHome]
//Создание твоего уведомления
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
    var data = NSDate()
    let dateformatter = DateFormatter()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let options : UNAuthorizationOptions = [.alert , .sound, .badge]
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        
        realmArray = myrealm.objects(placeDatabase.self)
        
        if places1.count != realmArray.count {
            for _ in 0...places1.count - realmArray.count - 1 {
                let createRealm = placeDatabase(value: ["time": 0])
                try! myrealm.write {
                    myrealm.add(createRealm)
                }
            }
        }
        
        for i in 0...places1.count - 1 {
            places1[i].time = realmArray[i].time
        }
        
        FirebaseApp.configure()
        
        dateformatter.dateFormat = "dd"
        
        print("Current data = ", dateformatter.string(from: data as Date))
        print("Current data = ", data)
        
        

        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        let destinationLocation = places.placeGZ.coordinate
        
        mytimer.invalidate()
        
        for place in places1 {
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
                    //Отправление уведомления
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
                    
                    //print ("2")
                    //myViewController?.setTravelTime()
                })
            }
        }
    
        let myViewController = self.window?.rootViewController as? ViewController
        mytimer2 = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {
            _ in
            myViewController?.inPolygon = false
             myViewController?.setDestinationLocation()
           // print ("3")
            //myViewController?.setTravelTime()
        })
        
        return true
    }
   

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        mytimer2.invalidate()
        print ("background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        let myViewController = self.window?.rootViewController as? ViewController
        myViewController?.sourceLocation = locationManager.location?.coordinate ?? places.placeIZM.coordinate
        
        mytimer2 = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {
            _ in
            myViewController?.inPolygon = false
            myViewController?.setDestinationLocation()
            //print ("4")
            //myViewController?.setTravelTime()
        })
        print("выход из background")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
       print("active")
    }

    func applicationWillTerminate(_ application: UIApplication) {
       print("terminate")
        realmArray = myrealm.objects(placeDatabase.self)
        
        print("Terminate = ", realmArray.count)
        for i in 0...realmArray.count - 1 {
            let currentRealm = realmArray[i]
            try! myrealm.write {
                currentRealm.time = places1[i].time
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
                
                //print ("5")
                //myViewController?.setTravelTime()
                
            })
            myViewController?.setDestinationLocation()
            myViewController?.locationStatusLabel.text = "Таймер"
            //Для себя проверка
            print("Exit")
            print(region.identifier)
        }
    }
    
    

    //Когда пользователь входит в какой-то регион
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
       
        if region is CLCircularRegion {
            let myViewController = self.window?.rootViewController as? ViewController
            let userInfo = [ "place" : allplaces[region.identifier]]
            myViewController?.sourceLocation = locationManager.location?.coordinate ?? places.placeIZM.coordinate
            
            //myViewController!.mapView.removeOverlays(myViewController!.mapView.overlays)
            mytimer2.invalidate()
            mytimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {
                _ in allplaces[region.identifier]?.time = allplaces[region.identifier]!.time + 1
                myViewController?.inPolygon = true
                NotificationCenter.default.post(name: .DtoV1TNotificationKey, object: nil, userInfo: userInfo)
                //print ("7")
                myViewController?.setDestinationLocation()
                
            })
            myViewController?.setDestinationLocation()
            let content = UNMutableNotificationContent()
            content.title = "Вы вошли в полигон"
            content.body = allplaces[region.identifier]?.title ?? "Главное здание"
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let request = UNNotificationRequest(identifier: "enterPoligon", content: content, trigger: trigger)
            
            notificationCenter.add(request, withCompletionHandler: nil)
            
            //Для себя проверка
            print("Enter")
            print(region.identifier)
        }
    }
    
  
    
}
