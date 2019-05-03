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

let mapCode = MapCode()
let places = Places()
let weekSh = [
    Schedule(name:"Понедельник"),
    Schedule(name:"Вторник"),
    Schedule(name:"Среда"),
    Schedule(name:"Четверг"),
    Schedule(name:"Пятница"),
    Schedule(name:"Суббота"),
    Schedule(name:"Воскресенье")
]
/*
 1.Добавить геофенсинг
 2.При его помощи допилить таймеры, статусы и навигацию
 3. После добавить статистику
 4. Добавить в расписание геоданные
 5. Интегрировать расписание и статисткиу в firebase
 6. ...
 */

class ViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var infoCard: CardInfoView!
    
    @IBOutlet var currentTaskLabel: UILabel! //Показывает текущую пару, либо "Свобода"
    
    @IBOutlet var univercityTimerLabel: UILabel! //Если в зоне, то суммирует время к таймеру, иначе показыает сколько добираться
    
    @IBOutlet var taskStatusLabel: UILabel! //Показывает опаздываю я или нет
    
    @IBOutlet var locationStatusLabel: UILabel! // Если в зоне, то суммирует время к таймеру, иначе показыает сколько добираться (Вы в бауманке/До бауманки)
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setExercice()
        
        mapView.addAnnotation(places.placeGZ)
        
        mapView.delegate = self
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        let initialLocation = CLLocation(latitude:55.765790, longitude: 37.677132)
        mapCode.centerMapOnLocation(location: locationManager.location ?? initialLocation,mapView: mapView)
        
        mapView.showsUserLocation = true
        mapView.showsTraffic = true
        let sourceLocation = locationManager.location?.coordinate
        let destinationLocation = places.placeGZ.coordinate
        
        mapCode.createRoute(sourceLocation: sourceLocation ?? initialLocation.coordinate,destinationLocation: destinationLocation,mapView: mapView)
         mapView.delegate = self
        
}
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
    func setExercice(){
        let sh = weekSh[Date().dayNumberOfWeek()!-2]
        let a = getNumberOfExercise()
        if a != -1{
            currentTaskLabel.text = sh.array[a].name
        }
        else {
            currentTaskLabel.text = "Свобода"
        }
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


func getNumberOfExercise()->Int{
    let date = Date()
    let calendar = Calendar.current
    let curtime = Int(calendar.component(.hour, from:date)*60*60+calendar.component(.minute, from:date)*60)
    
    let sh = weekSh[Date().dayNumberOfWeek()!-2]
    
    for i in 0...sh.array.count-1 {
        if curtime < sh.array[i].time.getSeconds()+5400 && curtime > sh.array[i].time.getSeconds() {
            return i
        }
    }
    return -1
}







