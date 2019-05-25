//
//  ViewController3.swift
//  BMSTudent
//
//  Created by Сергей Алехин on 15/05/2019.
//  Copyright © 2019 Sergei. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController3: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
   
    
    var Group: [String] = ["ИУ5-21", "ИУ5-22", "ИУ5-23", "ИУ5-24", "ИУ5-25"]
    
    let place : [Place] = [places.placeGZ, places.placeULK, places.placeESM, places.placeIZM, places.placeSK, places.placeOB, places.placeRKT, places.placeLESTEX, places.placeAS, places.placeREAIM, places.placeTC, places.placeHome]
    
    let myrealm = try! Realm()
    var realmArray: Results<placeDatabase>!
    
    var yourCurrentGroup: String = "ИУ5-21Б"
    let cellIdentifier = "statPoligonTableViewCell"
    var TextField: UITextField!
    
    let refresh = UIRefreshControl()
    
    
    @IBOutlet weak var mynavigationBar: UINavigationBar!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    @IBOutlet weak var TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarTitle.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: #selector(createGroupAlert))
        
        realmArray = myrealm.objects(placeDatabase.self)
        
        if place.count != realmArray.count {
            for _ in 0...place.count - realmArray.count - 1 {
                let createRealm = placeDatabase(value: ["time": 0])
                try! myrealm.write {
                    myrealm.add(createRealm)
                }
            }
        }
        
        for i in 0...place.count - 1 {
            place[i].time = realmArray[i].time
        }
        refreshdata()
        navBarTitle.title = yourCurrentGroup
        //yourGroupLabel.text = "Ваша группа: " + yourCurrentGroup
        TableView.delegate = self
        TableView.dataSource = self
        TableView.register(UINib.init(nibName: "statPoligonTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return place.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name: String = place[indexPath.row].title!
        let time: String = timeToString(time: realmArray[indexPath.row].time)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let castedcell = cell as? statPoligonTableViewCell {
            castedcell.fillNameAndTimeCell(with: name, with: time)
        }
        return cell
    }
    
    @objc func tableViewReload() {
        
        for i in 0...realmArray.count - 1 {
            let currentRealm = realmArray[i]
            try! myrealm.write {
                currentRealm.time = place[i].time
            }
        }
        TableView.reloadData()
        
        refresh.endRefreshing()
        
        
    }
    
    func refreshdata(){
        TableView.addSubview(refresh)
        refresh.addTarget(self, action: #selector(tableViewReload), for: .valueChanged)
    }
    
    @objc func createGroupAlert() {
        let groupAlert = UIAlertController(title: "Введите вашу группу", message: nil, preferredStyle: .alert)
        
        groupAlert.addTextField(configurationHandler: TextField)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: self.groupOkAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        groupAlert.addAction(okAction)
        groupAlert.addAction(cancelAction)
        
        self.present(groupAlert, animated: true)
    }
    
    func TextField(textField: UITextField) {
        TextField = textField
        TextField.placeholder = "ИУ5-25"
    }
    
    func groupOkAction(alert: UIAlertAction) {
    
        var groupChange = false
        
        for currentGroup in Group {
            if  currentGroup == TextField.text?.uppercased() {
                yourCurrentGroup = TextField.text?.uppercased() ?? "ИУ5-25"
                navBarTitle.title = yourCurrentGroup
                //yourGroupLabel.text = "Ваша группа: " + yourCurrentGroup
                groupChange = true
                }
            if (currentGroup == "ИУ5-25") && (groupChange == false) {
                wrongInputAlert()
            }
        }
        
    }
    
    func wrongInputAlert() {
        let alert = UIAlertController(title: "Вы неправильно ввели вашу группу, попробуйте еще раз", message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Continue", style: .default, handler: self.alertOkAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    func alertOkAction(alert: UIAlertAction) {
        createGroupAlert()
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
        if h < 1 {return String(m) + " м " + String(s) + " с"}
        if (h >= 1)&&(h < 100) {return String(h) + " ч " + String(m) + " м"}
        else {return String(h) + " ч"}
        
    }
    
}
