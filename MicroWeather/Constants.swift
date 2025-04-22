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
