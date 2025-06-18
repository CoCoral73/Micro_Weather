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

enum PMAPIType {
    case tmCoordinate
    case nearStation
    case measurement
    
    var endpoint: String {
        switch self {
        case .tmCoordinate:
            return "http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getTMStdrCrdnt"
        case .nearStation:
            return "http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList"
        case .measurement:
            return "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
        }
    }
    
    var modelType: Decodable.Type {
        switch self {
        case .tmCoordinate:
            return TM_Response.self
        case .nearStation:
            return Station_Response.self
        case .measurement:
            return Measurement_Response.self
        }
    }
}

enum FetchError: Error {
    case networkingError
    case dataError
    case parseError
    case castingError
    
    var description: String {
        switch self {
        case .networkingError:
            return "통신 오류"
        case .dataError:
            return "데이터 없음"
        case .parseError:
            return "JSON 파싱 오류"
        case .castingError:
            return "타입캐스팅 오류"
        }
    }
}
