//
//  PMCollectionViewCell.swift
//  MicroWeather
//
//  Created by 김정원 on 6/4/25.
//

import UIKit

class PMCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var data: PMValue? {
        didSet {
            setupUIwithData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backView.clipsToBounds = true
        backView.layer.cornerRadius = 10
    }
    
    private func setupUIwithData() {
        guard let data = data else { return }
        
        titleLabel.text = data.titleString
        titleLabel.textColor = .white
        stateLabel.text = data.stateString
        stateLabel.textColor = .white
        valueLabel.text = data.valueString
        valueLabel.textColor = .white
        
        //백뷰 색깔 설정
        let color: UIColor
        switch data.stateString {
        case "매우 좋음": color = #colorLiteral(red: 0.16215083, green: 0.542455256, blue: 0.9598863721, alpha: 1)
        case "좋음": color = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        case "양호": color = #colorLiteral(red: 0.1176956668, green: 0.7644996643, blue: 0.8110282421, alpha: 1)
        case "보통": color = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        case "나쁨": color = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        case "상당히 나쁨": color = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        case "매우 나쁨": color = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        case "최악": color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        default: color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
        
        backView.backgroundColor = color
    }
}
