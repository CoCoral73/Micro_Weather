//
//  WeatherManager.swift
//  MicroWeather
//
//  Created by 김정원 on 4/21/25.
//

import UIKit

final class WeatherManager {
    static let shared = WeatherManager()
    private init() {
        
    }
    
    private let apiManager = WeatherAPIManager.shared
    
    func fetchUltraShortTermObsr(completionHandler: @escaping () -> Void) {
        apiManager.fetchWeatherData(apiType: .ultraSrtNcst) { result in
            switch result {
            case .success(let model):
                if let obs = model as? UltraShortTermObservations {

                }
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler()
            }
        }
    }

}
