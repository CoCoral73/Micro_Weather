//
//  AddressManager.swift
//  MicroWeather
//
//  Created by 김정원 on 6/18/25.
//

import Foundation

struct Address: Codable {
    let region_type: String?  //H(행정동) or B(법정동)
    let region_1depth_name: String  // 도시
    let region_2depth_name: String  // 시/군/구
    let region_3depth_name: String  // 읍/면/동
    let code: String?    //행정코드
    
    var address: String {
        return "\(region_2depth_name) \(region_3depth_name)"
    }
    var full_address: String {
        return "\(region_1depth_name) \(region_2depth_name) \(region_3depth_name)"
    }
}

final class AddressManager {
    static let shared = AddressManager()
    private init() { }
    
    private lazy var allAddress: [Address] = loadAddress()
    
    func loadAddress() -> [Address] {
        guard let url = Bundle.main.url(forResource: "addressList", withExtension: "json") else {
            print("파일을 찾을 수 없습니다.")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let addresses = try decoder.decode([Address].self, from: data)
            return addresses
        } catch {
            print("디코딩 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func getAddress() -> [Address] {
        return allAddress
    }
    
    func filterAddress(keyword: String) -> [Address] {
        let keyword = keyword.replacingOccurrences(of: " ", with: "")
        
        return allAddress.filter { address in
            let keywords = extractSearchKeywords(from: address.full_address)
            return keywords.contains { $0.contains(keyword) }
        }
    }
    
    /// 검색용 키워드 추출
    func extractSearchKeywords(from address: String) -> [String] {
        var result = [String]()

        let noSpace = address.replacingOccurrences(of: " ", with: "")
        result.append(noSpace)

        // "사당3동" → "사당", "사당동"
        let pattern = #"([가-힣]+)\d+동"#
        if let match = noSpace.range(of: pattern, options: .regularExpression) {
            let base = String(noSpace[match]).replacingOccurrences(of: "동", with: "")
            let onlyName = base.replacingOccurrences(of: "\\d+", with: "", options: .regularExpression)
            result.append(onlyName)
            result.append(onlyName + "동")
        }

        return Array(Set(result)) // 중복 제거
    }
}
