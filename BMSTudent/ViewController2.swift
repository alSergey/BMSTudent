//
//  ViewController2.swift
//  BMSTudent
//
//  Created by Сергей Алехин on 11/05/2019.
//  Copyright © 2019 Sergei. All rights reserved.
//
import UIKit
import FirebaseDatabase

class ViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var scheduleToday: [Any] = ["Пусто","Пусто"]
    var Group: [String] = ["ИУ5-21", "ИУ5-22", "ИУ5-23", "ИУ5-24", "ИУ5-25"]
    var yourgroup: String?
    
    let refresh = UIRefreshControl()
   
    
    

    @IBOutlet weak var tableView: UITableView!
    let cellIdentifier = "myTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshdata()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "myTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        refreshdata()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleToday.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let location = segue.destination as? ViewController
        location?.yourgroup = yourgroup ?? "ИУ5-25"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let castedcell = cell as? myTableViewCell {
            let i = indexPath.row
            if(i == 0){
                castedcell.fillCell(with:Date().stringDayNumberOfWeek()!)
            }
            else{
                let str = scheduleToday[indexPath.row] as! String
                let strArr = str.split(separator: "_")
                 castedcell.fillCell(with:String(strArr[0]))
            }
        }
        return cell
    }
    
    @objc func tableViewReload() {
        let ref = Database.database().reference()

        ref.child(yourgroup ?? "ИУ5-25" + "/" + Date().stringDayNumberOfWeek()!).observeSingleEvent(of: .value) { (snapshot) in
            let name = snapshot.value as? [Any]
            self.scheduleToday = name ?? ["Не загрузилось","Не загрузилось"]
            for a in name!{
                print("testing... ",a)
            }
        }
        tableView.reloadData()
        refresh.endRefreshing()
    }

    func refreshdata(){
        refresh.addTarget(self, action: #selector(tableViewReload), for: .valueChanged)
        tableView.addSubview(refresh)
    }
}
extension Date {
    func stringDayNumberOfWeek() -> String? {
        switch Calendar.current.dateComponents([.weekday], from: self).weekday{
        case 1:
            return "Воскресенье"
            
        case 2:
            return "Понедельник"
           
        case 3:
            return "Вторник"
           
        case 4:
            return "Среда"
            
        case 5:
            return "Четверг"
        
        case 6:
            return "Пятница"
            
        case 7:
            return "Суббота"
           
        default :
            return "Среда"
         
        }
    }
}
