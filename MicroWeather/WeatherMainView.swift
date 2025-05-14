//
//  WeatherMainView.swift
//  MicroWeather
//
//  Created by 김정원 on 5/14/25.
//

import UIKit

class WeatherMainView: UIView {
    
    
    
    let redButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitle("Red", for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 1
        button.backgroundColor = MyColor.red.backgroundColor
        button.setTitleColor(MyColor.red.buttonColor, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
