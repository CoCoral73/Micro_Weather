//
//  Constants.swift
//  MicroWeather
//
//  Created by 김정원 on 4/21/25.
//

import UIKit

public enum WeatherAPIType {
    case ultraSrtNst
    case ultraSrtFst
    case vilageFst
    case fstVersion
    
    var endpoint: String {
        switch self {
        case .ultraSrtNst:
            return "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst"
        case .ultraSrtFst:
            return "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst"
        case .vilageFst:
            return "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"
        case .fstVersion:
            return "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getFcstVersion"
        }
    }
    
    var modelType: Decodable.Type {
        switch self {
        case .ultraSrtNst:
            return UltraShortTermObservations.self
        case .ultraSrtFst:
            return UltraShortTermForecast.self
        case .vilageFst:
            return ShortTermForecast.self
        case .fstVersion:
            return ForecastVersion.self
        }
    }
}
