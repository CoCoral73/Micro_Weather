//
//  UltraShortTermForecastCell.swift
//  MicroWeather
//
//  Created by 김정원 on 4/22/25.
//

import UIKit

class UltraShortTermForecastCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    var forecast: ForecastValue? {
        didSet {
            configureUIwithData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureUIwithData() {
        timeLabel.text = "\(forecast?.dateString ?? "") \(forecast?.timeString ?? "")"
        tempLabel.text = "\(forecast?.temp ?? "--")°"
        iconView.image = forecast?.icon
    }
}
