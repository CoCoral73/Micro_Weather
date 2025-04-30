//
//  ReverseGeocodeManager.swift
//  MicroWeather
//
//  Created by 김정원 on 4/30/25.
//

import UIKit
import CoreLocation

struct RegionCode: Codable {
    let region_1depth_name: String  // 시/도
    let region_2depth_name: String  // 시/군/구
    let region_3depth_name: String  // 읍/면/동
    
    var address: String {
        return "\(region_1depth_name)\(region_2depth_name.replacingOccurrences(of: " ", with: ""))\(region_3depth_name)"
    }
}

struct KakaoResponse: Codable {
    let documents: [RegionCode]
}

final class ReverseGeocodeManager {
    static let shared = ReverseGeocodeManager()
    private init() {
        guard let apiKey = ReverseGeocodeManager.loadAPIKey() else {
            fatalError("🔑 Kakao API Key 불러오기 실패")
        }
        self.apiKey = apiKey
    }
    
    private let apiKey: String
    
    func fetchAddress(location: CLLocation, completion: @escaping (String?) -> Void) {
        let (longitude, latitude) = (location.coordinate.longitude, location.coordinate.latitude)
        
        let urlString = "https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=\(longitude)&y=\(latitude)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, resp, error in
            guard error == nil,
                  let data = data,
                  let kakao = try? JSONDecoder().decode(KakaoResponse.self, from: data),
                  let first = kakao.documents.first else {
                completion(nil)
                return
            }

            completion(first.address)
        }.resume()
    }
    
    private static func loadAPIKey() -> String? {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization
                          .propertyList(from: data, format: nil)
                  as? [String: Any]
        else { return nil }
        return dict["KakaoAPIKey"] as? String
    }
}
