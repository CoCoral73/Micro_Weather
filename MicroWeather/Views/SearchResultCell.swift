//
//  SearchResultCell.swift
//  MicroWeather
//
//  Created by 김정원 on 6/17/25.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    
    var address: Address? {
        didSet {
            configureUIwithData()
        }
    }
    
    private func configureUIwithData() {
        addressLabel.text = address?.full_address
    }

}
