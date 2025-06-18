//
//  File.swift
//  MicroWeather
//
//  Created by 김정원 on 5/29/25.
//

import UIKit

final class ServiceKeyManager {
    static let shared = ServiceKeyManager()
    private init() {
        guard let apiKey = ServiceKeyManager.loadAPIServiceKey() else {
            fatalError("🔑 API Service Key 불러오기 실패")
        }
        self.serviceKey = apiKey
    }
    
    private let serviceKey: String
    
    func getServiceKey() -> String {
        return serviceKey
    }
    
    private static func loadAPIServiceKey() -> String? {
      guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization
                        .propertyList(from: data, format: nil)
                as? [String: Any]
      else { return nil }
      return dict["APIServiceKey"] as? String
    }
}
