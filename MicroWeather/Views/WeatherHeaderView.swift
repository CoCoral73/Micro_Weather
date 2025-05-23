//
//  WeatherHeaderView.swift
//  MicroWeather
//
//  Created by 김정원 on 5/14/25.
//

import UIKit

final class WeatherHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var refreshButton: UIButton!
    
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
    
    @IBOutlet weak var basetimeLabel2: UILabel!
    @IBOutlet weak var updatetimeLabel2: UILabel!
    @IBOutlet weak var stackView2: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        stackView2.arrangedSubviews.forEach {
            $0.isHidden = true
        }
        // 1) 제약 반영
        self.layoutIfNeeded()

        // 2) fitting size 계산 (너비는 superview 또는 테이블뷰 폭에 맞춰 주세요)
        let targetSize = CGSize(
            width: superview?.bounds.width ?? UIScreen.main.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let fittingSize = self.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        // 3) 프레임 크기 갱신
        self.frame.size = fittingSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 원형 코너 설정
        currentLocationButton.layer.cornerRadius = currentLocationButton.bounds.width / 2

        // 그림자 경로
        let path = UIBezierPath(roundedRect: currentLocationButton.bounds,
                                cornerRadius: currentLocationButton.bounds.width / 2)
        currentLocationButton.layer.shadowPath = path.cgPath

        // 그림자 설정
        currentLocationButton.layer.shadowColor   = UIColor.black.cgColor
        currentLocationButton.layer.shadowOpacity = 0.2
        currentLocationButton.layer.shadowOffset  = CGSize(width: 0, height: 2)
        currentLocationButton.layer.shadowRadius  = 6
        
        
        refreshButton.layer.cornerRadius = refreshButton.bounds.width / 2

        // 그림자 경로
        let path2 = UIBezierPath(roundedRect: refreshButton.bounds,
                                cornerRadius: refreshButton.bounds.width / 2)
        refreshButton.layer.shadowPath = path2.cgPath

        // 그림자 설정
        refreshButton.layer.shadowColor   = UIColor.black.cgColor
        refreshButton.layer.shadowOpacity = 0.2
        refreshButton.layer.shadowOffset  = CGSize(width: 0, height: 2)
        refreshButton.layer.shadowRadius  = 6
        

    }
}
