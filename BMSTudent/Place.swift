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
import RealmSwift

class Place:NSObject,MKAnnotation {
    let region: CLCircularRegion
    let title: String?
    let identifier: String
    let locationName: String
    let discipline: String
    var coordinate: CLLocationCoordinate2D
    var time: Int
    
   
    
    init(region: CLCircularRegion,title: String,identifier: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D, time: Int) {
        self.region = region
        self.title = title
        self.identifier = identifier
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
    let placeGZ = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.765886, longitude: 37.685041), radius: 190, identifier: "GZ"),
                        title: "Главное здание",
                        identifier: "GZ",
                        locationName: "2-я Бауманская",
                        discipline: "Корпус",
                        coordinate: CLLocationCoordinate2D(latitude: 55.765886, longitude: 37.685041),
                        time: 0)
    
    let placeULK = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.771514, longitude:37.692053), radius: 150, identifier: "ULK"),
                        title: "Учебно-лабораторный корпус",
                        identifier: "ULK",
                         locationName: "",
                         discipline: "Корпус",
                         coordinate: CLLocationCoordinate2D(latitude: 55.771514, longitude:37.692053),
                         time: 0)
    
    let placeESM = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.769411, longitude:37.689765), radius: 115, identifier: "ESM"),
                         title: "Корпус Э и СМ",
                         identifier: "ESM",
                         locationName: "2-я Бауманская",
                         discipline: "Корпус",
                         coordinate: CLLocationCoordinate2D(latitude: 55.769411, longitude:37.689765),
                         time: 0)
    
    let placeIZM = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.789398, longitude: 37.792557), radius: 200, identifier: "IZM"),
                         title: "Измайловские общаги",
                         identifier: "IZM",
                         locationName: "2-я Бауманская",
                         discipline: "Спорт и общаги",
                         coordinate: CLLocationCoordinate2D(latitude: 55.789398, longitude: 37.792557),
                         time: 0)
    
    let placeSK = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.772581, longitude: 37.697626), radius: 160, identifier: "SK"),
                        title: "Спортивный комплекс",
                        identifier: "SK",
                        locationName: "2-я Бауманская",
                        discipline: "Спорт и общаги",
                        coordinate: CLLocationCoordinate2D(latitude: 55.772581, longitude: 37.697626),
                        time: 0)
    
    let placeOB = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.770526, longitude: 37.687419), radius: 70, identifier: "OB"),
                        title: "Общага на Бауманской",
                        identifier: "OB",
                        locationName: "2-я Бауманская",
                        discipline: "Спорт и общаги",
                        coordinate: CLLocationCoordinate2D(latitude: 55.770526, longitude: 37.687419),
                        time: 0)
    
    let placeHome = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.891578, longitude: 37.723226), radius: 80, identifier: "Home"),
                          title: "Дом",
                          identifier: "Home",
                          locationName: "Семашко",
                          discipline: "Дом",
                          coordinate: CLLocationCoordinate2D(latitude: 55.891578, longitude: 37.723226),
                          time: 0)
    init(){
        let places : [String: Place] = ["GZ" : placeGZ, "ULK" : placeULK, "ESM" : placeESM, "IZM" : placeIZM, "SK" : placeSK, "OB" : placeOB, "Home" : placeHome]
    }
    // let places : [String: Place] = ["GZ" : placeGZ, "ULK" : placeULK, "ESM" : placeESM, "IZM" : placeIZM, "SK" : placeSK, "OB" : placeOB, "Home" : placeHome]

}

class placeDatabase: Object {
    @objc dynamic var time: Int = 0
}

