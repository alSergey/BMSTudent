//
//  ViewController.swift
//  BMSTudent
//
//  Created by Sergei Petrenko on 02/05/2019.
//  Copyright © 2019 Sergei. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseAuth



let mapCode = MapCode()
let places = Places()
var changeSize = false
var lastPlace = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.765886, longitude: 37.685041), radius: 190, identifier: "GZ"),
                                   title: "Последняя локация",
                                   identifier: "loc",
                                   locationName: "адрес",
                                   discipline: "лок",
                                   coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
                                   time: 0)

let pl : [String: Place] = ["GZ" : places.placeGZ, "ULK" : places.placeULK, "ESM" : places.placeESM, "IZM" : places.placeIZM, "SK" : places.placeSK, "OB" : places.placeOB, "RKT" : places.placeRKT, "LESTEX" : places.placeLESTEX, "AS" : places.placeAS, "REAIM" : places.placeREAIM, "TC" : places.placeTC, "Home" : places.placeHome]

let scheduleUrl = "http://flexhub.ru/static/serGEY.json";

var scheduleToday: [Any] = ["Пусто","Пусто"]


class ViewController: UIViewController {
  

    var yourgroup: String = "ИУ5-25"
    var heightConstraint: NSLayoutConstraint!
    
    var mySchedule = MySchedule() // расписание с сервера
    var myDaySchedule : [MyScheduleElement] = [] //расписание на текущий день
    var inPolygon = false
    var sourceLocation = CLLocationCoordinate2D(latitude:55.765790, longitude: 37.677132)
    var destinationLocation = places.placeGZ.coordinate
    
    @IBOutlet var cardInfoButton: UIButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var infoCard: CardInfoView!
    @IBOutlet var currentTaskLabel: UILabel! //Показывает текущую пару, либо "Свобода"
    @IBOutlet var univercityTimerLabel: UILabel! //Если в зоне, то суммирует время к таймеру, иначе показыает сколько добираться
    @IBOutlet var taskStatusLabel: UILabel! //Показывает опаздываю я или нет
    @IBOutlet var locationStatusLabel: UILabel! // Если в зоне, то суммирует время к таймеру, иначе показыает сколько добираться (Вы в бауманке/До бауманки)
    
    let locationManager = CLLocationManager()
    let initialLocation = CLLocation(latitude:55.765790, longitude: 37.677132)
    let mylocation = CLLocationCoordinate2D(latitude: 55.765804, longitude: 37.685734)


    override func viewDidLoad() {
        super.viewDidLoad()
        //Подписка на уведомление
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceived(_:)), name: .myNotificationKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceivedT(_:)), name: .DtoV1TNotificationKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceivedZ(_:)), name: .DtoV1ZNotificationKey, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceivedM(_:)), name: .mapPlaceNotificationKey, object: nil)
       
        
        addMapTrackingButton()
        textView.isEditable = false
        mapView.showsCompass = false
        
        let buttonItem = MKUserTrackingBarButtonItem(mapView: mapView)
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        self.navigationItem.rightBarButtonItem = buttonItem
    
        //setTravelTime()
        setScheduleTextView()
        addAnnotation()
        
        notifyOn()
        mapView.delegate = self
        locationManager.delegate = self
        lastPlace.coordinate = (locationManager.location?.coordinate) ?? CLLocationCoordinate2D(latitude:55.765790, longitude: 37.677132)
    
        prepareLocationManager()
   
        mapCode.centerMapOnLocation(location: locationManager.location ?? initialLocation,mapView: mapView)
        mapView.showsScale = true
        mapView.showsUserLocation = true
        mapView.showsTraffic = true
        sourceLocation = locationManager.location?.coordinate ?? initialLocation.coordinate
        destinationLocation = places.placeGZ.coordinate
    
    }
    func prepareLocationManager(){
        //Ставим геофенсинг на регионы
        locationManager.startMonitoring(for: places.placeGZ.region)
        locationManager.startMonitoring(for: places.placeULK.region)
        locationManager.startMonitoring(for: places.placeESM.region)
        locationManager.startMonitoring(for: places.placeIZM.region)
        locationManager.startMonitoring(for: places.placeSK.region)
        locationManager.startMonitoring(for: places.placeOB.region)
        locationManager.startMonitoring(for: places.placeRKT.region)
        locationManager.startMonitoring(for: places.placeLESTEX.region)
        locationManager.startMonitoring(for: places.placeAS.region)
        locationManager.startMonitoring(for: places.placeREAIM.region)
        locationManager.startMonitoring(for: places.placeTC.region)
        locationManager.startMonitoring(for: places.placeHome.region)
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringVisits()
        locationManager.distanceFilter = 35
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    //Действие при приему уведомления
    @objc func notificationReceived(_ notification: Notification) {
        guard let text = notification.userInfo?["text"] as? String else { return }
        //Группа которая передана с View3
        yourgroup = text
        print("View1", yourgroup)
    }
    
    @objc func notificationReceivedT(_ notification: Notification) {
        guard let text = notification.userInfo?["place"] as? Place else { return }
        setTimeLabel(region: text)
    }
    
    @objc func notificationReceivedZ(_ notification: Notification) {
        setTimeZero()
    }
    
    @objc func notificationReceivedM(_ notification: Notification) {
        guard let text = notification.userInfo?["place"] as? Place else { return }
        //let region = MKCoordinateRegion(center: text.coordinate, latitudinalMeters: CLLocationDistance(5000), longitudinalMeters: CLLocationDistance(5000))
        //mapView.setRegion(region, animated: true)
        mapView.setCenter(text.coordinate, animated: true)
    }

    func setScheduleTextView(){
        let ref = Database.database().reference()
        ref.child(yourgroup  + "/" + Date().stringDayNumberOfWeek()!).observeSingleEvent(of: .value) { (snapshot) in
            let name = snapshot.value as? [Any]
            scheduleToday = name ?? ["Не загрузилось","Не загрузилось"]
            let curEx = self.getCurrentExId(cTime: getCurrentTime())
            if curEx != 0 && curEx <= scheduleToday.count {
                let str = scheduleToday[curEx] as? String
                self.currentTaskLabel.text = String(str!.split(separator: "_")[0])
            }
            else {
                self.currentTaskLabel.text = "Свобода"
            }
            self.setDestinationLocation()
        }
        
    }
    @IBAction func onClick(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            if !changeSize{
                //self.groupButton.isHidden = false
                self.cardInfoButton.setTitle("Скрыть", for: .normal)
                //self.setScheduleTextView()
                self.loadScheduleTodayTV()
                self.infoCard.frame =  CGRect(x:self.infoCard.frame.minX, y: self.infoCard.frame.minY, width:self.infoCard.frame.width, height:self.infoCard.frame.height*4)
                self.textView.frame = CGRect(x:self.textView.frame.minX, y: self.textView.frame.minY, width:self.textView.frame.width, height:self.textView.frame.height*8)
                changeSize = !changeSize
            }
            else{
                //self.groupButton.isHidden = true
                self.cardInfoButton.setTitle("Показать", for: .normal)
                self.textView.text = "Расписание"
                self.infoCard.frame =  CGRect(x:self.infoCard.frame.minX, y: self.infoCard.frame.minY, width:self.infoCard.frame.width, height:self.infoCard.frame.height/4)
                self.textView.frame = CGRect(x:self.textView.frame.minX, y: self.textView.frame.minY, width:self.textView.frame.width, height:self.textView.frame.height/8)
                changeSize = !changeSize
            }
        }) { (success) in
            print("Animation Successful!")
        }
        
    }
    func loadScheduleTodayTV(){
         self.textView.text += "\n"
        for i in 1...scheduleToday.count-1{
            let str = scheduleToday[i] as! String
            self.textView.text += String(str.split(separator: "_")[0]) + "\n"
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
   
    
    
    func timeToString(time : Int)->String{
        var h: Int = 0
        var m: Int = 0
        var s: Int = 0

        if time < 60 {s = time}
        else if time < 3600 {
            m = time / 60
            s = time - 60 * (time / 60)

        }
        else {
            h = time / 3600
            m = time / 60 - h * 60
            s = time - 3600 * h - 60 * m
        }
        return String(h) + ":" + String(m) + ":" + String(s)

    }

    func setTimeLabel(region:Place){
        locationStatusLabel.text = "Вы в бауманке"
        self.univercityTimerLabel.text = timeToString(time: region.time)
    }
    
    func setDestinationLocation(){
        let curEx = self.getCurrentExId(cTime: getCurrentTime())
        mapView.removeOverlays(mapView.overlays)
        if (curEx != 0 && curEx < scheduleToday.count-1){
            print("curEx",curEx, " ", scheduleToday.count)
            let str = scheduleToday[curEx+1] as? String
            let tag = String(str!.split(separator: "_")[1])
            
            print("destination ",tag)
            destinationLocation = (pl[tag]?.coordinate)!
            setTimer(dl:destinationLocation)
        
    }
    
        else {
            self.locationStatusLabel.text = "Таймер"
            self.univercityTimerLabel.text = "00:00:00"
            print("no destination ")
        }
    }
    
    func addMapTrackingButton(){
        let buttonItem = MKUserTrackingButton(mapView: mapView)
        buttonItem.frame = CGRect(origin: CGPoint(x:self.view.bounds.width-52, y: self.view.bounds.height-136), size: CGSize(width: 50, height: 50))
        mapView.addSubview(buttonItem)
    }
    
    func getCurrentExId(cTime: Int)->Int{
        //let cTime = getCurrentTime()
        if cTime > timeToSeconds(h: 8, m: 30) && cTime < timeToSeconds(h: 9, m: 15){
            print("1 пара")
            return 1
        }
        else if cTime > timeToSeconds(h: 10, m: 15) && cTime < timeToSeconds(h: 11, m: 50){
            print("2 пара")
            return 2
        }
        else if cTime > timeToSeconds(h: 12, m: 0) && cTime < timeToSeconds(h: 13, m: 35){
            print("3 пара")
            return 3
        }
        else if cTime > timeToSeconds(h: 13, m: 50) && cTime < timeToSeconds(h: 15, m: 25){
            print("4 пара")
            return 4
        }
        else if cTime > timeToSeconds(h: 15, m: 40) && cTime < timeToSeconds(h: 17, m: 15){
            print("5 пара")
            return 5
        }
        else if cTime > timeToSeconds(h: 17, m: 30) && cTime < timeToSeconds(h: 19, m: 0){
            print("6 пара")
            return 6
        }
        else if cTime > timeToSeconds(h: 19, m: 15) && cTime < timeToSeconds(h: 20, m: 45){
            print("7 пара")
            return 7
        }
        
        else{
         return 0
        }
        
    }
    func setTimer(dl: CLLocationCoordinate2D){
        
        //let time = mapCode.getRouteTime(sourceLocation: (locationManager.location?.coordinate)!, destinationLocation: dl, mapView: mapView)
        var time: Int = 0
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceLocation ))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationLocation))
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate{ (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions==\(error.localizedDescription)")
                }
                return
            }
            
            let route = directionResonse.routes[0]
            let res =  Int(route.expectedTravelTime)
            time = res
//            self.locationStatusLabel.text = "Время в пути"
//            self.univercityTimerLabel.text = self.timeToString(time: res)
            
            if(!self.contains(place: pl, point: self.locationManager.location?.coordinate ?? self.initialLocation.coordinate )){
                self.mapView.removeOverlays(self.mapView.overlays)
                self.sourceLocation = (self.locationManager.location?.coordinate) ?? CLLocationCoordinate2D(latitude:55.765790, longitude: 37.677132)
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                let rect = route.polyline.boundingMapRect
                self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                self.locationStatusLabel.text = "Время в пути"
                print("ставлю время в пути", time )
                self.univercityTimerLabel.text = self.timeToString(time: time)
            }
            
            
        }
    
        
        
        
        
        
//        if(!contains(place: pl, point: locationManager.location?.coordinate ?? initialLocation.coordinate )){ // тут проверка на нахождение в одном месте и присутсивие вне полигона
//            if !contains(place: ["loc":lastPlace], point: (locationManager.location?.coordinate) ?? initialLocation.coordinate){
//                lastPlace.coordinate = locationManager.location?.coordinate ?? initialLocation.coordinate
//                lastPlace.coordinate = (locationManager.location?.coordinate) ?? places.placeGZ.coordinate
//                print("Переместились")
//                mapView.removeOverlays(mapView.overlays)
//                sourceLocation = (locationManager.location?.coordinate) ?? CLLocationCoordinate2D(latitude:55.765790, longitude: 37.677132)
//                mapCode.createRoute(sourceLocation: sourceLocation ,destinationLocation: destinationLocation,mapView: mapView)
//                locationStatusLabel.text = "Время в пути"
//                print("Время в пути", time )
//                univercityTimerLabel.text = timeToString(time: time)
//            }
//            else{
//                print("Нет перемещения")
//                print("Время в пути", timeToString(time: time))
//                locationStatusLabel.text = "Время в пути"
//                univercityTimerLabel.text = timeToString(time: time)
//                sourceLocation = (locationManager.location?.coordinate)!
//            }
//            print("Days ",myDaySchedule.count)
        
        
//            for i in 0...myDaySchedule.count-2{
//                print(myDaySchedule[i].time)
//                print("test ",myDaySchedule[i].getTimeInMillis()," ",getCurrentTime(), " time=",time)
//                if myDaySchedule[i].getTimeInMillis()<=getCurrentTime() && myDaySchedule[i+1].getTimeInMillis()>getCurrentTime(){
//                    if getCurrentTime()+time<myDaySchedule[i].getTimeInMillis(){
//                        if myDaySchedule[i].title.rawValue == "Свобода"{
//                            print("успеваете ",myDaySchedule[i].getTimeInMillis()," ",getCurrentTime(), " time=",time)
//                            taskStatusLabel.text = "Успеваете на " + myDaySchedule[i+1].title.rawValue
//                        }
//                        else{
//                            print("опаздываете ",myDaySchedule[i].getTimeInMillis()," ",getCurrentTime(), " time=",time)
//                            univercityTimerLabel.text = timeToString(time: time)
//                            taskStatusLabel.text = "Опаздываете на " + myDaySchedule[i].title.rawValue
//                        }
//                    }
//                    else{
//                        if myDaySchedule[i].title.rawValue == "Свобода"{
//                            print("опаздываете ",myDaySchedule[i].getTimeInMillis()," ",getCurrentTime(), " time=",time)
//                            univercityTimerLabel.text = timeToString(time: time)
//                            taskStatusLabel.text = "Опаздываете на " + myDaySchedule[i+1].title.rawValue
//                        }
//                        else{
//                            print("опаздываете ",myDaySchedule[i].getTimeInMillis()," ",getCurrentTime(), " time=",time)
//                            univercityTimerLabel.text = timeToString(time: time)
//                            taskStatusLabel.text = "Опаздываете на " + myDaySchedule[i].title.rawValue
//                        }
//                    }
//                }
//                else{
//                    print("Никуда не надо")
//                    mapView.removeOverlays(mapView.overlays)
//                    univercityTimerLabel.text = timeToString(time: time)
//                }
//            }
        
    }


    /*
    func setTravelTime(){
        setDestinationLocation()
        let time = mapCode.getRouteTime(sourceLocation: sourceLocation, destinationLocation: destinationLocation, mapView: mapView)
        
        if(!contains(place: pl, point: locationManager.location?.coordinate ?? initialLocation.coordinate )){ // тут проверка на нахождение в одном месте и присутсивие вне полигона
            if !contains(place: ["loc":lastPlace], point: (locationManager.location?.coordinate) ?? CLLocationCoordinate2D(latitude:55.765790, longitude: 37.677132)){
                 lastPlace.coordinate = (locationManager.location?.coordinate) ?? CLLocationCoordinate2D(latitude:55.765790, longitude: 37.677132)
            lastPlace.coordinate = (locationManager.location?.coordinate) ?? places.placeGZ.coordinate
              print("Переместились")
        mapView.removeOverlays(mapView.overlays)
        sourceLocation = (locationManager.location?.coordinate) ?? CLLocationCoordinate2D(latitude:55.765790, longitude: 37.677132)
        mapCode.createRoute(sourceLocation: sourceLocation ,destinationLocation: destinationLocation,mapView: mapView)
        locationStatusLabel.text = "Время в пути"
        univercityTimerLabel.text = timeToString(time: time)
            }
            else{
                print("Нет перемещения")
                univercityTimerLabel.text = timeToString(time: time)
                sourceLocation = (locationManager.location?.coordinate)!
            }
            print("Days ",myDaySchedule.count)
            
            for i in 0...myDaySchedule.count-2{
                print(myDaySchedule[i].time)
                print("test ",myDaySchedule[i].getTimeInMillis()," ",getCurrentTime(), " time=",time)
                if myDaySchedule[i].getTimeInMillis()<=getCurrentTime() && myDaySchedule[i+1].getTimeInMillis()>getCurrentTime(){
                    if getCurrentTime()+time<myDaySchedule[i].getTimeInMillis(){
                        if myDaySchedule[i].title.rawValue == "Свобода"{
                            print("успеваете ",myDaySchedule[i].getTimeInMillis()," ",getCurrentTime(), " time=",time)
                            taskStatusLabel.text = "Успеваете на " + myDaySchedule[i+1].title.rawValue
                        }
                        else{
                            print("опаздываете ",myDaySchedule[i].getTimeInMillis()," ",getCurrentTime(), " time=",time)
                            univercityTimerLabel.text = timeToString(time: time)
                            taskStatusLabel.text = "Опаздываете на " + myDaySchedule[i].title.rawValue
                        }
                    }
                    else{
                         if myDaySchedule[i].title.rawValue == "Свобода"{
                        print("опаздываете ",myDaySchedule[i].getTimeInMillis()," ",getCurrentTime(), " time=",time)
                        univercityTimerLabel.text = timeToString(time: time)
                        taskStatusLabel.text = "Опаздываете на " + myDaySchedule[i+1].title.rawValue
                        }
                         else{
                            print("опаздываете ",myDaySchedule[i].getTimeInMillis()," ",getCurrentTime(), " time=",time)
                            univercityTimerLabel.text = timeToString(time: time)
                            taskStatusLabel.text = "Опаздываете на " + myDaySchedule[i].title.rawValue
                        }
                    }
                }
                else{
                    print("Никуда не надо")
                    mapView.removeOverlays(mapView.overlays)
                    univercityTimerLabel.text = timeToString(time: time)
                }
            }
        }
        
    
    }
    */
    
    //Проверка нахождения в одном из полигонов
    func contains(place: [String : Place], point: CLLocationCoordinate2D)->Bool{//потом будем возвращать код региона
        for pl in place{
            let c = CLCircularRegion(center: pl.value.coordinate, radius: 100.0,identifier: pl.key)
            if c.contains(point){
                print("inside polygon ", pl.key)
                return true
            }
        }
        print("outside polygon ")
        return false
    }
    
    func setTimeZero(){
        univercityTimerLabel.text = "00:00:00"
    }
    
    
    func addAnnotation() {
        mapView.addAnnotation(places.placeGZ)
        mapView.addAnnotation(places.placeULK)
        mapView.addAnnotation(places.placeESM)
        mapView.addAnnotation(places.placeIZM)
        mapView.addAnnotation(places.placeSK)
        mapView.addAnnotation(places.placeOB)
        mapView.addAnnotation(places.placeRKT)
        mapView.addAnnotation(places.placeLESTEX)
        mapView.addAnnotation(places.placeAS)
        mapView.addAnnotation(places.placeREAIM)
        mapView.addAnnotation(places.placeTC)
        mapView.addAnnotation(places.placeHome)
        //mapView.setRegion(places.placeGZ.region, animated: true)
        //mapView?.addOverlay(MKCircle(center: places.placeGZ.coordinate, radius: places.placeGZ.region.radius))
    }
    
    func notifyOn() {
        places.placeGZ.region.notifyOnEntry = true
        places.placeGZ.region.notifyOnExit = true
        places.placeULK.region.notifyOnEntry = true
        places.placeULK.region.notifyOnExit = true
        places.placeESM.region.notifyOnEntry = true
        places.placeESM.region.notifyOnExit = true
        places.placeIZM.region.notifyOnEntry = true
        places.placeIZM.region.notifyOnExit = true
        places.placeSK.region.notifyOnEntry = true
        places.placeSK.region.notifyOnExit = true
        places.placeOB.region.notifyOnEntry = true
        places.placeOB.region.notifyOnExit = true
        places.placeRKT.region.notifyOnEntry = true
        places.placeRKT.region.notifyOnExit = true
        places.placeLESTEX.region.notifyOnEntry = true
        places.placeLESTEX.region.notifyOnExit = true
        places.placeAS.region.notifyOnEntry = true
        places.placeAS.region.notifyOnExit = true
        places.placeREAIM.region.notifyOnEntry = true
        places.placeREAIM.region.notifyOnExit = true
        places.placeTC.region.notifyOnEntry = true
        places.placeTC.region.notifyOnExit = true
        places.placeHome.region.notifyOnEntry = true
        places.placeHome.region.notifyOnExit = true
    }
}
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Place else { return nil }
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Place
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}
extension ViewController: CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapCode.centerMapOnLocation(location: location,mapView: mapView)
            locationManager.stopUpdatingLocation()
            
        }
    }
}
extension Date {//1-воскресенье
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}

func getCurrentTime()->Int{
    let date = Date()
    let calendar = Calendar.current
    let curtime = Int(calendar.component(.hour, from:date)*60*60+calendar.component(.minute, from:date)*60)
    return curtime
}
func timeToSeconds(h:Int, m:Int)->Int{
    return h*60*60+m*60
}










