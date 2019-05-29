import UIKit
import FirebaseDatabase
import RealmSwift

extension Notification.Name {
    public static let mapPlaceSheduleNotificationKey = Notification.Name(rawValue: "mapPlaceShedule")
}

class ViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var groupArray: [String] = []
    var yourCurrentGroup: String = "ИУ5-25"
    
    let myrealm = try! Realm()
    var realmGroupArray: Results<groupDatabase>!
    
    var sections: [String] = ["Воскресенье","Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]
    var itemsInSections: [[String]] = [[""], [""], [""], [""], [""], [""], [""]]
    
    let refresh = UIRefreshControl()
   
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    let cellIdentifier = "myTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ref = Database.database().reference()
        ref.child("groups").observeSingleEvent(of: .value) { (snapshot) in
            let name = snapshot.value as? [String]
            self.groupArray = name ?? ["ИУ5-21", "ИУ5-22", "ИУ5-23", "ИУ5-24", "ИУ5-25"]
            print(self.groupArray)
        }
        
        realmGroupArray = myrealm.objects(groupDatabase.self)
        yourCurrentGroup = realmGroupArray[0].yourGroup
        
        let weekday = Calendar.current.component(.weekday, from: Date())
        navBar.title = stringDayNumberOfWeek(i: weekday)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceived(_:)), name: .changeGroupNotificationKey, object: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "myTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        ref.child(yourCurrentGroup).observeSingleEvent(of: .value) { (snapshot) in
            let name = snapshot.value as? [String:[Any]]
            print(name ?? "Name")
            for i in 1...7 {
                var day = name![Date().stringDayNumberOfWeek(i:i)!]
                day?.remove(at: 0)
                print("day ",day as! [String])
                self.itemsInSections[i-1] = day as! [String]
                print("item ",self.itemsInSections[i-1])
            }
            print("items", self.itemsInSections)
            self.tableView.reloadData()
        }
        refreshdata()
    }
   
    //Запись выбранной на view3 группы в yourGroup
    @objc func notificationReceived(_ notification: Notification) {
        guard let text = notification.userInfo?["text"] as? String else { return }
        yourCurrentGroup = text
        
        let ref = Database.database().reference()
        ref.child(yourCurrentGroup).observeSingleEvent(of: .value) { (snapshot) in
            let name = snapshot.value as? [String:[Any]]
            print(name ?? "Name")
            for i in 1...7 {
                var day = name![Date().stringDayNumberOfWeek(i:i)!]
                day?.remove(at: 0)
                print("day ",day as! [String])
                self.itemsInSections[i-1] = day as! [String]
                print("item ",self.itemsInSections[i-1])
            }
            print("items", self.itemsInSections)
            self.tableView.reloadData()
        }
        
        refreshdata()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let location = segue.destination as? ViewController
        location?.yourgroup = yourCurrentGroup
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let text = itemsInSections[indexPath.section][indexPath.row]
        if text.contains("_") && text != "Выходной" && text != "NULL"{
        let text2 = text.split(separator: "_")[0]
            cell.textLabel!.text = String(text2) + " " + Date().getTimeStringOfEx(exId: indexPath.row)
        }
        else if text == "Выходной"{
            cell.textLabel!.text = text
        }
        else if text == "NULL"{
             cell.textLabel!.text = "Окно"
        }

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sheduleMap = itemsInSections[indexPath.section][indexPath.row]
        let shedulePlaceIndex = String(sheduleMap.split(separator: "_")[1]) as String
        let userInfo = [ "placeIndex" : shedulePlaceIndex]
        NotificationCenter.default.post(name: .mapPlaceSheduleNotificationKey, object: nil, userInfo: userInfo)
        tableView.reloadData()
        self.tabBarController?.selectedIndex = 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsInSections[section].count
    }
    
    @objc func tableViewReload() {
        let ref = Database.database().reference()
        ref.child(yourCurrentGroup).observeSingleEvent(of: .value) { (snapshot) in
            let name = snapshot.value as? [String:[Any]]
            for i in 1...7 {
                var day = name![Date().stringDayNumberOfWeek(i:i)!]
                day?.remove(at: 0)
                print("day ",day as! [String])
                self.itemsInSections[i-1] = day as! [String]
                print("item ",self.itemsInSections[i-1])
            }
            print("items", self.itemsInSections)
            self.tableView.reloadData()
        }
        tableView.reloadData()
        refresh.endRefreshing()
    }

    func refreshdata(){
        refresh.addTarget(self, action: #selector(tableViewReload), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    
    func stringDayNumberOfWeek(i:Int) -> String? {
        switch i {
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
    
    func stringDayNumberOfWeek(i:Int) -> String? {
        switch i {
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
    
    func getTimeStringOfEx(exId: Int)->String{
        switch exId{
        case 0:
            return "8:30 - 10:00"
        case 1:
            return "10:15 - 11:45"
        case 2:
            return "12:00 - 13:30"
        case 3:
            return "13:50 - 15:25"
        case 4:
            return "15:40 - 17:15"
        case 5:
            return "17:30 - 19:00"
        case 6:
            return "19:15 - 20:45"
        default:
            return " "
        }
    }
}
