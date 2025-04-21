//
//  WeatherAPIManager.swift
//  MicroWeather
//
//  Created by 김정원 on 4/18/25.
//

import UIKit

final class WeatherAPIManager {
    static let shared = WeatherAPIManager()
    private init() {
        guard let apiKey = WeatherAPIManager.loadAPIServiceKey() else {
            fatalError("🔑 API Service Key 불러오기 실패")
        }
        self.serviceKey = apiKey
    }
    
    private let serviceKey: String
    
    private static func loadAPIServiceKey() -> String? {
      guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization
                        .propertyList(from: data, format: nil)
                as? [String: Any]
      else { return nil }
      return dict["WeatherAPIServiceKey"] as? String
    }
}
