import UIKit

class myTableViewCell: UITableViewCell {

    @IBOutlet weak var groupLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Заполнение TableViewCell
    func fillCell(with group: String){
        groupLabel.text = group
    }
    
}
