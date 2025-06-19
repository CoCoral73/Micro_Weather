//
//  PMFooterCollectionViewCell.swift
//  MicroWeather
//
//  Created by 김정원 on 6/19/25.
//

import UIKit

class PMFooterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    
    var stationName: String? {
        didSet {
            setupUIwithData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 10
    }
    
    func setupUIwithData() {
        stationNameLabel.textColor = .white
        fromLabel.textColor = .white
        stationNameLabel.text = "측정소 이름: \(stationName ?? "-")"
        fromLabel.text = "해당 데이터는 한국환경공단(에어코리아)에서 제공하는 \"측정소별 실시간 측정정보\" 데이터로, 실제 대기농도 수치와 다를 수 있습니다."
    }
}
