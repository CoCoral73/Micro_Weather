//
//  Constants.swift
//  MicroWeather
//
//  Created by 김정원 on 4/21/25.
//

import UIKit

public enum WeatherAPIType {
    case ultraSrtNcst
    case ultraSrtFcst
    case srtFcst
    
    var endpoint: String {
        switch self {
        case .ultraSrtNcst:
            return "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst"
        case .ultraSrtFcst:
            return "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst"
        case .srtFcst:
            return "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"
        }
    }
    
    var modelType: Decodable.Type {
        switch self {
        case .ultraSrtNcst:
            return UltraShortTermNowcast.self
        case .ultraSrtFcst:
            return UltraShortTermForecast.self
        case .srtFcst:
            return ShortTermForecast.self
        }
    }
}

enum CompassDirection8: CaseIterable {
    case north      // 북
    case northEast  // 북동
    case east       // 동
    case southEast  // 남동
    case south      // 남
    case southWest  // 남서
    case west       // 서
    case northWest  // 북서

    /// 한글 설명
    var description: String {
        switch self {
        case .north:     return "북"
        case .northEast: return "북동"
        case .east:      return "동"
        case .southEast: return "남동"
        case .south:     return "남"
        case .southWest: return "남서"
        case .west:      return "서"
        case .northWest: return "북서"
        }
    }

    /// 도(°) 값을 받아 해당 8방위로 초기화
    init(from degrees: Double) {
        // 360°를 8등분 → 각 구간은 45° 폭
        // 중앙값을 맞추기 위해 22.5°를 더하고
        // 45°로 나눈 뒤 floor → 0...7 인덱스로 변환
        let sectors = Double(Self.allCases.count)    // 8
        let step = 360.0 / sectors                   // 45.0
        let halfStep = step / 2                      // 22.5
        let rawIndex = Int(floor((degrees + halfStep) / step))
        let index = rawIndex % CompassDirection8.allCases.count
        self = Self.allCases[index]
    }
}
