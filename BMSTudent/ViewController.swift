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
var lastPlace = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.765886, longitude: 37.685041), radius: 190, identifier: "GZ"),
                                   title: "Последняя локация",
                                   identifier: "loc",
                                   locationName: "адрес",
                                   discipline: "лок",
                                   coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
                                   time: 0)

 let pl : [String: Place] = ["GZ" : places.placeGZ, "ULK" : places.placeULK, "ESM" : places.placeESM, "IZM" : places.placeIZM, "SK" : places.placeSK, "OB" : places.placeOB, "Home" : places.placeHome]

let scheduleUrl = "http://flexhub.ru/static/serGEY.json";

class ViewController: UIViewController {
  
    
    
    var mySchedule = MySchedule() // расписание с сервера
    var myDaySchedule : [MyScheduleElement] = [] //расписание на текущий день
    var inPolygon = false
    var sourceLocation = CLLocationCoordinate2D(latitude:55.765790, longitude: 37.677132)
    var destinationLocation = places.placeGZ.coordinate
    
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
        
        // Подгрузка расписания из затычки
        do{
        self.mySchedule = try MySchedule(fromURL: URL(string: scheduleUrl)!)
        print(self.mySchedule.count)
        for a1 in self.mySchedule{
            print("\n", a1.key, "\n")
            for i in 0...a1.value.count-1{
                print(a1.value[i].title," ",a1.value[i].time," ",a1.value[i].location)
                
            }
        }
        }
        catch{
            
        }
        
        setExercice() // адаптировано под новые данные
        
        addAnnotation()
        setTravelTime()
        
        notifyOn()
        mapView.delegate = self
        locationManager.delegate = self
        lastPlace.coordinate = (locationManager.location?.coordinate)!
    
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
        locationManager.startMonitoring(for: places.placeHome.region)
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringVisits()
        locationManager.distanceFilter = 35
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    @IBAction func onClick(_ sender: Any) {
        //увеличение 
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
    func setExercice(){
            myDaySchedule = mySchedule["Понедельник"]!
            switch Int(Date().dayNumberOfWeek()!-2){
            case 0:
                print("TODAY 0")
                myDaySchedule = mySchedule["Понедельник"]!
                break;
            case 1:
                print("TODAY 1")
                 myDaySchedule = mySchedule["Вторник"]!
                break;
            case 2:
                print("TODAY 2")
                 myDaySchedule = mySchedule["Среда"]!
                break;
            case 3:
                print("TODAY 3")
                 myDaySchedule = mySchedule["Четверг"]!
                break;
            case 4:
                print("TODAY 4")
                 myDaySchedule = mySchedule["Пятница"]!
                break;
            case 5:
                print("TODAY 5")
                 myDaySchedule = mySchedule["Суббота"]!
                break;
            case 6:
                print("TODAY 6")
                 myDaySchedule = mySchedule["Воскресенье"]!
                break;
            case 7:
                 print("TODAY 7")
                break;
            default:
                print("TODAY ???")
            }
        textView.text = ""
        for i in 0...myDaySchedule.count-1{
            print(myDaySchedule[i].title.rawValue)
            if i != myDaySchedule.count-1{
            textView.text += myDaySchedule[i].title.rawValue+" "+myDaySchedule[i].time+"-"+myDaySchedule[i+1].time+"\n"
            }
            else{
                textView.text += myDaySchedule[i].title.rawValue+" "+myDaySchedule[i].time + "\n"
            }
            if myDaySchedule[i].getTimeInMillis()<=getCurrentTime() && myDaySchedule[i+1].getTimeInMillis()>getCurrentTime(){
                currentTaskLabel.text = myDaySchedule[i].title.rawValue
            }
            else{
                currentTaskLabel.text = "Свобода"
            }
        }
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
        taskStatusLabel.text = "Вы успеваете на пару"
        univercityTimerLabel.text = timeToString(time: region.time)
    }
    func setDestinationLocation(){
        for i in 0...myDaySchedule.count-1{
            print(myDaySchedule[i].title.rawValue)
            if myDaySchedule[i].getTimeInMillis()<=getCurrentTime() && myDaySchedule[i+1].getTimeInMillis()>getCurrentTime(){
                print("Нужно в ",myDaySchedule[i+1].location.rawValue )
                destinationLocation = pl[myDaySchedule[i+1].location.rawValue]?.coordinate ?? initialLocation.coordinate // перепроверить индексы
            }
            else{
                print("Вы вне расписания")
                destinationLocation = (pl[myDaySchedule[0].location.rawValue]?.coordinate)!
            }
        }
    }
    func setTravelTime(){
        print("setTravelTime")
        let time = mapCode.getRouteTime(sourceLocation: sourceLocation, destinationLocation: destinationLocation, mapView: mapView)
        
        if(!contains(place: pl, point: (locationManager.location?.coordinate)!) ){ // тут проверка на нахождение в одном месте и присутсивие вне полигона
            if !contains(place: ["loc":lastPlace], point: (locationManager.location?.coordinate)!){
                 lastPlace.coordinate = (locationManager.location?.coordinate)!
            
            lastPlace.coordinate = (locationManager.location?.coordinate)!
              print("Не в полигоне")
        setDestinationLocation()
        
        mapView.removeOverlays(mapView.overlays)
        sourceLocation = (locationManager.location?.coordinate)!
        mapCode.createRoute(sourceLocation: sourceLocation ,destinationLocation: destinationLocation,mapView: mapView)
        locationStatusLabel.text = "Время в пути"
        //let time = mapCode.getRouteTime(sourceLocation: sourceLocation, destinationLocation: destinationLocation, mapView: mapView)
        
        univercityTimerLabel.text = timeToString(time: time)
            for i in 0...myDaySchedule.count-1{
                print(myDaySchedule[i].time)
                if myDaySchedule[i].getTimeInMillis()<=getCurrentTime() && myDaySchedule[i+1].getTimeInMillis()>getCurrentTime(){
                    if getCurrentTime()+time>myDaySchedule[i].getTimeInMillis(){
                        currentTaskLabel.text = "Опаздываете"
                         univercityTimerLabel.text = timeToString(time: time)
                    }
                    else{
                        currentTaskLabel.text = "На месте"
                    }
                }
                else{
                    univercityTimerLabel.text = timeToString(time: time)
                    currentTaskLabel.text = "Успеваете"
                }
            }
            
        }
            else{
                print("Нет перемещения")
                univercityTimerLabel.text = timeToString(time: time)
                sourceLocation = (locationManager.location?.coordinate)!
            }
        }
        else {
            currentTaskLabel.text = "Вы в МГТУ"
        }
        
        

    }
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
extension Date {
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









