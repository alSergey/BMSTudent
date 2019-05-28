//
//  MapCode.swift
//  BMSTudent
//
//  Created by Sergei Petrenko on 03/05/2019.
//  Copyright © 2019 Sergei. All rights reserved.
//

import Foundation
import MapKit

class MapCode{
    
func createRoute(sourceLocation : CLLocationCoordinate2D, destinationLocation : CLLocationCoordinate2D, mapView: MKMapView){
    //let initialLocation = CLLocation(latitude:55.765790, longitude: 37.677132)
    
    let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation )
    let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
    
    let directionRequest = MKDirections.Request()
    directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
    directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
    directionRequest.transportType = .walking
    
    let directions = MKDirections(request: directionRequest)
    directions.calculate { (response, error) in
        guard let directionResonse = response else {
            if let error = error {
                print("we have error getting directions==\(error.localizedDescription)")
            }
            return
        }
        
        //get route and assign to our route variable
        let route = directionResonse.routes[0]
        
        //add route to our mapview
        mapView.addOverlay(route.polyline, level: .aboveRoads)
        //setting rect of our mapview to fit the two locations
        let rect = route.polyline.boundingMapRect
        mapView.setRegion(MKCoordinateRegion(rect), animated: true)
    }

}
    
    func getRouteTime(sourceLocation : CLLocationCoordinate2D, destinationLocation : CLLocationCoordinate2D, mapView: MKMapView)->Int{
        var myTime : Int = 0
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation )
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate{ (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions==\(error.localizedDescription)")
                }
                return
            }
            //get route and assign to our route variable
            let route = directionResonse.routes[0]
            let res =  Int(route.expectedTravelTime)
            myTime = res
    }
        print("test")
        print("res2",myTime)
        return myTime
    }
    
    let regionRadius: CLLocationDistance = 100
    
    func centerMapOnLocation(location: CLLocation, mapView: MKMapView) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.showsUserLocation = true
    }
    
}
