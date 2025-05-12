//
//  SearchTableViewCell.swift
//  MicroWeather
//
//  Created by 김정원 on 5/12/25.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func bookmarkButtonTapped(_ sender: UIButton) {
    }
    
}
