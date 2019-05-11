//
//  ViewController2.swift
//  BMSTudent
//
//  Created by Сергей Алехин on 11/05/2019.
//  Copyright © 2019 Sergei. All rights reserved.
//
import UIKit

class ViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var Group: [String] = ["ИУ5-21Б", "ИУ5-22Б", "ИУ5-23Б", "ИУ5-24Б", "ИУ5-25Б"]
    var yourgroup: String?
    
    @IBOutlet weak var yourGroup: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let cellIdentifier = "myTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yourGroup.text = Group[0]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "myTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Group.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let location = segue.destination as? ViewController
        location?.yourgroup = yourgroup ?? "ИУ5-21Б"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        yourgroup = Group[indexPath.row]
        yourGroup.text = yourgroup
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let castedcell = cell as? myTableViewCell {
            castedcell.fillCell(with: Group[indexPath.row])
        }
        return cell
    }
    
    
    

}
