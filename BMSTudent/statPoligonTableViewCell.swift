import UIKit

class statPoligonTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // Заполнение TableViewCell
    func fillNameAndTimeCell(with name: String, with time:  String) {
        nameLabel.text = name
        timeLabel.text = time
    }
    
}
