//
//  ReverseGeocodeManager.swift
//  MicroWeather
//
//  Created by 김정원 on 4/30/25.
//

import UIKit
import CoreLocation


struct AddressResponse: Codable {
    let documents: [AddressData]
}

struct AddressData: Codable {
    let region_type: String  //H(행정동) or B(법정동)
    let region_2depth_name: String  // 시/군/구
    let region_3depth_name: String  // 읍/면/동
    
    var address: String {
        return "\(region_2depth_name) \(region_3depth_name)"
    }
}

struct CoordinateResponse: Codable {
    let documents: [CoordinateData]
}

struct CoordinateData: Codable {
    let x, y: String
    let address: DetailAddress
    
    struct DetailAddress: Codable {
        let region_2depth_name: String
        let region_3depth_h_name: String
        
        var address: String {
            return "\(region_2depth_name) \(region_3depth_h_name)"
        }
    }
}

final class KakaoAPIManager {
    static let shared = KakaoAPIManager()
    private init() {
        guard let apiKey = KakaoAPIManager.loadAPIKey() else {
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
                  let decoded = try? JSONDecoder().decode(AddressResponse.self, from: data),
                  let type_H = decoded.documents.filter({ $0.region_type == "H" }).first else {
                completion(nil)
                return
            }
            
            completion(type_H.address)
        }.resume()
    }
    
    func fetchCoordinate(keyword: String, completion: @escaping ([CoordinateData]?) -> Void) {
        let urlString = "https://dapi.kakao.com/v2/local/search/address.json?query=\(keyword)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, resp, error in
            guard error == nil,
                    let data = data,
                  let decoded = try? JSONDecoder().decode(CoordinateResponse.self, from: data)
            else {
                completion(nil)
                return
            }
            
            completion(decoded.documents)
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
