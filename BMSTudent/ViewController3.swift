import UIKit
import RealmSwift
import FirebaseDatabase

extension Notification.Name {
    public static let changeGroupNotificationKey = Notification.Name(rawValue: "groupChange")
}

extension Notification.Name {
    public static let mapPlaceNotificationKey = Notification.Name(rawValue: "mapPlace")
}

class ViewController3: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var groupArray: [String] = []
    let placeArray: [Place] = [places.placeGZ, places.placeULK, places.placeESM, places.placeIZM, places.placeSK, places.placeOB, places.placeRKT, places.placeLESTEX, places.placeAS, places.placeREAIM, places.placeTC, places.placeHome, places.placeMail]
    
    let myrealm = try! Realm()
    var realmArray: Results<placeDatabase>!
    var realmGroupArray: Results<groupDatabase>!
    
    var yourCurrentGroup: String = "ИУ5-25"
    let cellIdentifier = "statPoligonTableViewCell"
    var TextField: UITextField!
    
    let refresh = UIRefreshControl()
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Подключение Realm баз данных
        realmArray = myrealm.objects(placeDatabase.self)
        realmGroupArray = myrealm.objects(groupDatabase.self)
        
        //
        let ref = Database.database().reference()
        ref.child("groups").observeSingleEvent(of: .value) { (snapshot) in
            let name = snapshot.value as? [String]
            self.groupArray = name ?? ["ИУ5-21", "ИУ5-22", "ИУ5-23", "ИУ5-24", "ИУ5-25"]
            print(self.groupArray)
        }
        
        // Добавление кнопки в NavigationController
        navBar.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ball_point_pen"), style: .done, target: self, action: #selector(createGroupAlert))
        yourCurrentGroup = realmGroupArray[0].yourGroup
        navBar.title = yourCurrentGroup
        
        // Обновление TableView
        refreshdata()
        
        // Инициализация TableView
        TableView.delegate = self
        TableView.dataSource = self
        TableView.register(UINib.init(nibName: "statPoligonTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    // Количество строк в TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeArray.count
    }
    
    // Заполнение TableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name: String = placeArray[indexPath.row].title!
        let time: String = timeToString(time: realmArray[indexPath.row].time)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let castedcell = cell as? statPoligonTableViewCell {
            castedcell.fillNameAndTimeCell(with: name, with: time)
        }
        return cell
    }
    
    // Дейсвтие по нажатии на TableViewCell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userInfo = [ "place" : placeArray[indexPath.row] ]
        NotificationCenter.default.post(name: .mapPlaceNotificationKey, object: nil, userInfo: userInfo)
        tableView.reloadData()
        self.tabBarController?.selectedIndex = 0
    }
    
    // Добавление свайп влепо по TableViewCell
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let resetAction = UITableViewRowAction(style: .default, title: "Сброс") { _, indexPath in
            let resetPlace = self.placeArray[indexPath.row]
            resetPlace.time = 0
            let currentRealm = self.realmArray[indexPath.row]
            try! self.myrealm.write {
                currentRealm.time = resetPlace.time
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                tableView.reloadData()
            }
        }
        return [resetAction]
    }
    
    // Обновление TableView
    @objc func tableViewReload() {
        for i in 0...realmArray.count - 1 {
            let currentRealm = realmArray[i]
            try! myrealm.write {
                currentRealm.time = placeArray[i].time
            }
        }
        TableView.reloadData()
        refresh.endRefreshing()
    }
    
    // Установка обновления TableView
    func refreshdata(){
        TableView.addSubview(refresh)
        refresh.addTarget(self, action: #selector(tableViewReload), for: .valueChanged)
    }
    
    // AlertView выбора группы
    @objc func createGroupAlert() {
        let groupAlert = UIAlertController(title: "Введите вашу группу", message: nil, preferredStyle: .alert)
        groupAlert.addTextField(configurationHandler: TextField)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: self.groupOkAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let ref = Database.database().reference()
        ref.child("groups").observeSingleEvent(of: .value) { (snapshot) in
            let name = snapshot.value as? [String]
            self.groupArray = name ?? ["ИУ5-21", "ИУ5-22", "ИУ5-23", "ИУ5-24", "ИУ5-25"]
            print(self.groupArray)
            
            groupAlert.addAction(okAction)
            groupAlert.addAction(cancelAction)
            
            self.present(groupAlert, animated: true)
        }
        
    }
    
    // TextField в AlertView
    func TextField(textField: UITextField) {
        TextField = textField
        TextField.placeholder = "ИУ5-21"
    }
    
    // Действие кнопки ОК в AlertView
    func groupOkAction(alert: UIAlertAction) {
        var groupChange = false
    
        for currentGroup in groupArray {
            if  currentGroup == TextField.text?.uppercased() {
                yourCurrentGroup = TextField.text?.uppercased() ?? "ИУ5-25"
                navBar.title = yourCurrentGroup
                let userInfo = [ "text" : yourCurrentGroup ]
                NotificationCenter.default.post(name: .changeGroupNotificationKey, object: nil, userInfo: userInfo)
                groupChange = true
                let currentRealm = realmGroupArray[0]
                try! myrealm.write {
                    currentRealm.yourGroup = yourCurrentGroup
                }
                }
            if (currentGroup == "ИУ5-25") && (groupChange == false) {
                wrongInputAlert()
            }
        }
    }
    
    // Если пользователь неправильно выбрал группу
    func wrongInputAlert() {
        let alert = UIAlertController(title: "Вы неправильно ввели вашу группу, попробуйте еще раз", message: nil, preferredStyle: .alert)
        print("error ",self.groupArray)
        let okAction = UIAlertAction(title: "Continue", style: .default, handler: self.alertOkAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    // Кнопка ОК при неправильном выборе группы
    func alertOkAction(alert: UIAlertAction) {
        createGroupAlert()
    }
    
    // Преобразование Int в String
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
        
        if time == 0 {return String(0)}
        if h < 1 {return String(m) + " м " + String(s) + " с"}
        if (h >= 1)&&(h < 100) {return String(h) + " ч " + String(m) + " м"}
        else {return String(h) + " ч"}
        
    }
    
    // Установка кастомной статистики
    func setCustomStat() {
        places.placeGZ.time = 13000
        places.placeULK.time = 80000
        places.placeESM.time = 12
        places.placeIZM.time = 1348
        places.placeSK.time = 14777
        places.placeOB.time = 0
        places.placeRKT.time = 140
        places.placeLESTEX.time = 14999000
        places.placeAS.time = 536
        places.placeREAIM.time = 159
        places.placeTC.time = 586
        places.placeHome.time = 145678
        places.placeMail.time = 1
        
        for i in 0...realmArray.count - 1 {
            let currentRealm = realmArray[i]
            try! myrealm.write {
                currentRealm.time = placeArray[i].time
            }
        }
    }
    
}
