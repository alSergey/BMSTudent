//
//  ViewController3.swift
//  BMSTudent
//
//  Created by Сергей Алехин on 15/05/2019.
//  Copyright © 2019 Sergei. All rights reserved.
//

import UIKit

class ViewController3: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var Group: [String] = ["ИУ5-21Б", "ИУ5-22Б", "ИУ5-23Б", "ИУ5-24Б", "ИУ5-25Б"]
    
    let place : [Place] = [places.placeGZ, places.placeULK, places.placeESM, places.placeIZM, places.placeSK, places.placeOB, places.placeHome]
    
    var yourCurrentGroup: String = "ИУ5-21Б"
    let cellIdentifier = "statPoligonTableViewCell"
    var TextField: UITextField!
    
    @IBOutlet weak var yourGroupLabel: UILabel!
    @IBOutlet weak var TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yourGroupLabel.text = "Ваша группа: " + yourCurrentGroup
        TableView.delegate = self
        TableView.dataSource = self
        TableView.register(UINib.init(nibName: "statPoligonTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return place.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name: String = place[indexPath.row].title!
        let time: Int = place[indexPath.row].time
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let castedcell = cell as? statPoligonTableViewCell {
            castedcell.fillNameAndTimeCell(with: name, with: time)
        }
        return cell
    }
    
    @IBAction func tableViewReload(_ sender: UIButton) {
        TableView.reloadData()
    }
    
    
    
    @IBAction func yourGroupChange(_ sender: UIButton) {
        createGroupAlert()
    }
    
    func createGroupAlert() {
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
        TextField.placeholder = "ИУ5-21Б"
    }
    
    func groupOkAction(alert: UIAlertAction) {
    
        var groupChange = false
        
        for currentGroup in Group {
            if  currentGroup == TextField.text {
                yourCurrentGroup = TextField.text ?? "ИУ5-21Б"
                yourGroupLabel.text = "Ваша группа: " + yourCurrentGroup
                
                let view2 = ViewController2()
                view2.yourgroup = yourCurrentGroup
                
                
                groupChange = true
                }
            if (currentGroup == "ИУ5-25Б") && (groupChange == false) {
                let alert = UIAlertController(title: "Вы неправильно ввели вашу группу, попробуйте еще раз", message: nil, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Continue", style: .default, handler: self.alertOkAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true)
            }
        }
        
    }
    
    func alertOkAction(alert: UIAlertAction) {
        createGroupAlert()
    }
}
