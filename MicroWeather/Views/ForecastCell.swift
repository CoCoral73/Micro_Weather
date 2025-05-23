//
//  UltraShortTermForecastCell.swift
//  MicroWeather
//
//  Created by 김정원 on 4/22/25.
//

import UIKit

class ForecastCell: UITableViewCell {

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
        guard let forecast = forecast else { return }
        if !forecast.isUltra {
            timeLabel.text = forecast.timeString
        } else {
            timeLabel.text = "\(forecast.dateString) \(forecast.timeString)"
        }
        tempLabel.text = "\(forecast.temp ?? "--")°"
        iconView.image = forecast.icon
    }
}
