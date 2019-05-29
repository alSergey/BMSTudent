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
                         title: "Измайловские СК и общаги",
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
    
    let placeRKT = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.926661, longitude: 37.810943), radius: 120, identifier: "RKT"),
                         title: "Ракетно-космический корпус",
                         identifier: "RKT",
                         locationName: "Королев",
                         discipline: "Корпус",
                         coordinate: CLLocationCoordinate2D(latitude: 55.926661, longitude: 37.810943),
                         time: 0)
    
    let placeLESTEX = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.927231, longitude: 37.791869), radius: 300, identifier: "LESTEX"),
                         title: "Лесо-технический корпус",
                         identifier: "LESTEX",
                         locationName: "Королев",
                         discipline: "Корпус",
                         coordinate: CLLocationCoordinate2D(latitude: 55.927231, longitude: 37.791869),
                         time: 0)
    
    let placeAS = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.762997, longitude: 37.870369), radius: 120, identifier: "AS"),
                         title: "Аэрокосмический корпус",
                         identifier: "AS",
                         locationName: "Реутов",
                         discipline: "Корпус",
                         coordinate: CLLocationCoordinate2D(latitude: 55.762997, longitude: 37.870369),
                         time: 0)
    
    let placeREAIM = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.741062, longitude: 37.724703), radius: 170, identifier: "REAIM"),
                         title: "Корпус РК и ПС",
                         identifier: "REAIM",
                         locationName: "Москва",
                         discipline: "Корпус",
                         coordinate: CLLocationCoordinate2D(latitude: 55.741062, longitude: 37.724703),
                         time: 0)
    
    let placeTC = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.765559, longitude: 37.677731), radius: 100, identifier: "TC"),
                           title: "Учебно-методический центр",
                           identifier: "TC",
                           locationName: "Москвас",
                           discipline: "Корпус",
                           coordinate: CLLocationCoordinate2D(latitude: 55.765559, longitude: 37.677731),
                           time: 0)
    
    let placeHome = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.891578, longitude: 37.723226), radius: 80, identifier: "Home"),
                          title: "Дом",
                          identifier: "Home",
                          locationName: "Семашко",
                          discipline: "Дом",
                          coordinate: CLLocationCoordinate2D(latitude: 55.891578, longitude: 37.723226),
                          time: 0)
    
    let placeMail = Place(region: CLCircularRegion(center: CLLocationCoordinate2D(latitude: 55.796931, longitude: 37.537847), radius: 120, identifier: "Mail"),
                          title: "Mail.ru",
                          identifier: "Mail",
                          locationName: "Москва",
                          discipline: "Mail",
                          coordinate: CLLocationCoordinate2D(latitude: 55.796931, longitude: 37.537847),
                          time: 0)
}

class placeDatabase: Object {
    @objc dynamic var time: Int = 0
}

