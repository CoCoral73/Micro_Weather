//
//  WeatherModel.swift
//  MicroWeather
//
//  Created by 김정원 on 4/22/25.
//

import UIKit

struct NowcastValue {
    var temp, hum, rain: String?
    var vec: Double?
    var wind: String?
    
    var feelsLike: String {
        guard let tempStr = temp, let temp = Double(tempStr) else {
            return "--"
        }
        let windSpeed = Double(wind ?? "0") ?? 0
        
        // 공식 적용 조건
        guard temp <= 10, windSpeed >= 4.8 else {
            return String(temp)  // 조건 미달 시 실제 기온 반환
        }
        // 풍속 지수 계산
        let v = pow(windSpeed, 0.16)
        // KMA 체감온도 공식
        let result = 13.12 + 0.6215 * temp - 11.37 * v + 0.3965  * temp * v
        
        return String(result)
    }
    var vecString: String {
        return CompassDirection16(from: vec ?? 0).description
    }
}

struct ForecastValue {
    var fcstdate, fcsttime: String?
    var temp: String?
}
