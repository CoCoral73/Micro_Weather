//
//  WeatherAPIConstants.swift
//  MicroWeather
//
//  Created by 김정원 on 5/12/25.
//

import UIKit

enum WeatherAPIType {
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
            return Nowcast.self
        case .ultraSrtFcst:
            return Forecast.self
        case .srtFcst:
            return Forecast.self
        }
    }
}

enum FetchError: Error {
    case networkingError
    case dataError
    case parseError
    
    var description: String {
        switch self {
        case .networkingError:
            return "통신 오류"
        case .dataError:
            return "데이터 없음"
        case .parseError:
            return "JSON 파싱 오류"
        }
    }
}
