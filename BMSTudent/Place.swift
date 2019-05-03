//
//  Place.swift
//  BMSTudent
//
//  Created by Sergei Petrenko on 02/05/2019.
//  Copyright © 2019 Sergei. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class Place: NSObject, MKAnnotation {
    let region: CLCircularRegion
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    var time: Int
    
    init(region: CLCircularRegion,title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D, time: Int) {
        self.region = region
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.time = time
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}
class Places{
    let placeGZ = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.765804, longitude: 37.685734), radius: 100, identifier: "GZ"),
                        title: "Главное здание",
                        locationName: "2-я Бауманская",
                        discipline: "Корпус",
                        coordinate: CLLocationCoordinate2D(latitude: 55.765804, longitude: 37.685734),
                        time: 0)
    
    let placeULK = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.771220, longitude:37.691521), radius: 100, identifier: "ULK"),
                        title: "Учебно-лабораторный корпус",
                         locationName: "",
                         discipline: "Корпус",
                         coordinate: CLLocationCoordinate2D(latitude: 55.771220, longitude:37.691521),
                         time: 0)
    
    let placeESM = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.769351, longitude:37.690162), radius: 100, identifier: "ESM"),
                         title: "Корпус Э и СМ",
                         locationName: "2-я Бауманская",
                         discipline: "Корпус",
                         coordinate: CLLocationCoordinate2D(latitude: 55.769351, longitude:37.690162),
                         time: 0)
    
    let placeIZM = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.787980, longitude: 37.783333), radius: 100, identifier: "IZM"),
                         title: "Измайловские общаги",
                         locationName: "2-я Бауманская",
                         discipline: "Спорт и общаги",
                         coordinate: CLLocationCoordinate2D(latitude: 55.787980, longitude: 37.783333),
                         time: 0)
    
    let placeSK = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.772227, longitude: 37.697592), radius: 100, identifier: "SK"),
                        title: "Спортивный комплекс",
                        locationName: "2-я Бауманская",
                        discipline: "Спорт и общаги",
                        coordinate: CLLocationCoordinate2D(latitude: 55.772227, longitude: 37.697592),
                        time: 0)
    
    let placeOB = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.770392, longitude: 37.688075), radius: 100, identifier: "OB"),
                        title: "Общага на Бауманской",
                        locationName: "2-я Бауманская",
                        discipline: "Спорт и общаги",
                        coordinate: CLLocationCoordinate2D(latitude: 55.770392, longitude: 37.688075),
                        time: 0)
    
    let placeHome = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.891555, longitude: 37.723244), radius: 100, identifier: "Home"),
                          title: "Дом",
                          locationName: "Семашко",
                          discipline: "Дом",
                          coordinate: CLLocationCoordinate2D(latitude: 55.891555, longitude: 37.723244),
                          time: 0)
    init(){
        let places : [String: Place] = ["GZ" : placeGZ, "ULK" : placeULK, "ESM" : placeESM, "IZM" : placeIZM, "SK" : placeSK, "OB" : placeOB, "Home" : placeHome]
    }
}
