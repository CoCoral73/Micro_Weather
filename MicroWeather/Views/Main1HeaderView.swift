//
//  WeatherHeaderView.swift
//  MicroWeather
//
//  Created by 김정원 on 5/14/25.
//

import UIKit

final class Main1HeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    
    @IBOutlet weak var humLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var vectorLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    @IBOutlet weak var basetimeLabel: UILabel!
    @IBOutlet weak var updatetimeLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var fcstBasetimeLabel: UILabel!
    @IBOutlet weak var line: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

}
