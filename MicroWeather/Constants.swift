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
    case fcstVersion
    
    var endpoint: String {
        switch self {
        case .ultraSrtNcst:
            return "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst"
        case .ultraSrtFcst:
            return "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst"
        case .srtFcst:
            return "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"
        case .fcstVersion:
            return "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getFcstVersion"
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
        case .fcstVersion:
            return ForecastVersion.self
        }
    }
}

/// 16방위 열거형
enum CompassDirection16: CaseIterable {
    case north            // 북
    case northNorthEast   // 북북동
    case northEast        // 북동
    case eastNorthEast    // 동북동
    case east             // 동
    case eastSouthEast    // 동남동
    case southEast        // 남동
    case southSouthEast   // 남남동
    case south            // 남
    case southSouthWest   // 남남서
    case southWest        // 남서
    case westSouthWest    // 서남서
    case west             // 서
    case westNorthWest    // 서북서
    case northWest        // 북서
    case northNorthWest   // 북북서

    /// 한글 설명
    var description: String {
        switch self {
        case .north:            return "북"
        case .northNorthEast:   return "북북동"
        case .northEast:        return "북동"
        case .eastNorthEast:    return "동북동"
        case .east:             return "동"
        case .eastSouthEast:    return "동남동"
        case .southEast:        return "남동"
        case .southSouthEast:   return "남남동"
        case .south:            return "남"
        case .southSouthWest:   return "남남서"
        case .southWest:        return "남서"
        case .westSouthWest:    return "서남서"
        case .west:             return "서"
        case .westNorthWest:    return "서북서"
        case .northWest:        return "북서"
        case .northNorthWest:   return "북북서"
        }
    }

    /// 도(°) 값을 받아 해당 16방위로 초기화
    init(from degrees: Double) {
        // 11.25°를 더한 후 22.5°로 나눠서 0…15 인덱스로
        let index = Int(floor((degrees + 11.25) / 22.5)) % CompassDirection16.allCases.count
        self = CompassDirection16.allCases[index]
    }
}
