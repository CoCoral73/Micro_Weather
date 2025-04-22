//
//  ViewController.swift
//  MicroWeather
//
//  Created by 김정원 on 4/18/25.
//

import UIKit

class WeatherViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    private func setupUI() {
        self.navigationItem.title = "서울시 동작구 사당4동"
        self.tabBarItem = UITabBarItem(title: "날씨", image: UIImage(systemName: "star"), selectedImage: UIImage(systemName: "star.fill"))
        
    }

}

