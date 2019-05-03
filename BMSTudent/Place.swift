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
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
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
    let placeGZ = Place(title: "Главное здание",
                        locationName: "2-я Бауманская",
                        discipline: "Корпус",
                        coordinate: CLLocationCoordinate2D(latitude: 55.765804, longitude: 37.685734))
    
    let placeULK = Place(title: "Учебно-лабораторный корпус",
                         locationName: "",
                         discipline: "Корпус",
                         coordinate: CLLocationCoordinate2D(latitude: 55.771220, longitude:37.691521))
    
    let placeESM = Place(title: "Корпус Э и СМ",
                         locationName: "2-я Бауманская",
                         discipline: "Корпус",
                         coordinate: CLLocationCoordinate2D(latitude: 55.769351, longitude:37.690162))
    
    let placeIZM = Place(title: "Измайловские общаги",
                         locationName: "2-я Бауманская",
                         discipline: "Спорт и общаги",
                         coordinate: CLLocationCoordinate2D(latitude: 55.787980, longitude: 37.783333))
    
    let placeSK = Place(title: "Спортивный комплекс",
                        locationName: "2-я Бауманская",
                        discipline: "Спорт и общаги",
                        coordinate: CLLocationCoordinate2D(latitude: 55.772227, longitude: 37.697592))
    
    let placeOB = Place(title: "Общага на Бауманской",
                        locationName: "2-я Бауманская",
                        discipline: "Спорт и общаги",
                        coordinate: CLLocationCoordinate2D(latitude: 55.770392, longitude: 37.688075))
    init(){
    let places : [String: Place] = ["GZ" : placeGZ, "ULK" : placeULK, "ESM" : placeESM, "IZM" : placeIZM, "SK" : placeSK, "OB" : placeOB]
    }
}
