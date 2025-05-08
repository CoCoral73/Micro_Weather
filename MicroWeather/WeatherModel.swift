//
//  WeatherModel.swift
//  MicroWeather
//
//  Created by 김정원 on 4/22/25.
//

import UIKit

struct NowcastValue {
    var temp, hum, rain: String?    //온도, 습도, 강수량
    var vec: Double?    //풍향 deg
    var wind: String?   //풍속 m/s
    
    var feelsLike: String {
        // 1) 섭씨 기온(Ta)와 상대습도(RH), 풍속(V) 확보
        guard let tempStr = temp,
              let Ta = Double(tempStr),
              let RHstr = hum,
              let RH = Double(RHstr)
        else { return "--" }
        
        // 2) 현재 월 판별 (5~9월: 여름, 그 외: 겨울)
        let month = Calendar.current.component(.month, from: Date())
        let isSummer = (5...9).contains(month)
        
        let result: Double
        if isSummer {
            // 여름철 공식: -0.2442 + 0.55399Tw + 0.45535Ta – 0.0022Tw² + 0.00278Tw·Ta + 3.0
            let Tw = wetBulbTemperature(temperature: Ta, humidity: RH)
            result = -0.2442
                   + 0.55399 * Tw
                   + 0.45535 * Ta
                   - 0.0022  * Tw * Tw
                   + 0.00278 * Tw * Ta
                   + 3.0
        } else {
            // 겨울철 공식 (조건: Ta ≤ 10°C, V ≥ 1.3 m/s)
            let windSpeed = (Double(wind ?? "0") ?? 0)
            if Ta <= 10, windSpeed >= 1.3 {
                let v16 = pow(windSpeed, 0.16)
                result = 13.12 + 0.6215 * Ta - 11.37 * v16 + 0.3965 * Ta * v16
            } else {
                result = Ta
            }
        }
        
        // 소수점 한 자리까지 반올림해서 문자열로 반환
        return String(format: "%.1f", result)
    }
    
    /// 16방위 풍향 문자열
    var vecString: String {
        return CompassDirection8(from: vec ?? 0).description
    }
    
    /// Stull 공식 기반 습구온도(Tw) 계산
    private func wetBulbTemperature(temperature Ta: Double, humidity RH: Double) -> Double {
        // Stull(2011) 근사식
        let term1 = Ta * atan(0.151977 * sqrt(RH + 8.313659))
        let term2 = atan(Ta + RH)
        let term3 = atan(RH - 1.67633)
        let term4 = 0.00391838 * pow(RH, 1.5) * atan(0.023101 * RH)
        // 최종
        return term1 + term2 - term3 + term4 - 4.686035
    }
}

struct ForecastValue {
    var fcstdate, fcsttime: String?
    var pty, sky: Int?
    var temp: String?
    
    var dateString: String {
        guard let fcstdate = fcstdate else { return "--" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyyMMdd"
        let fcstDate = dateFormatter.date(from: fcstdate)!
        
        let calendar = Calendar.current
        if calendar.isDateInToday(fcstDate) {
            return "오늘"
        } else if calendar.isDateInTomorrow(fcstDate) {
            return "내일"
        } else {
            dateFormatter.dateFormat = "MM월 dd일"
            return dateFormatter.string(from: fcstDate)
        }
    }
    
    var timeString: String {
        guard let fcsttime = fcsttime else { return "--" }
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.dateFormat = "HHmm"
        let fcstTime = timeFormatter.date(from: fcsttime)!
        
        timeFormatter.dateFormat = "HH시"
        return timeFormatter.string(from: fcstTime)
    }
    
    var icon: UIImage? {
        guard let pty = pty, let sky = sky else { return nil }
        
        switch pty {
        case 1: // 비
            return UIImage(systemName: "cloud.heavyrain")
        case 2: // 비/눈
            return UIImage(systemName: "cloud.sleet")
        case 3: // 눈
            return UIImage(systemName: "snowflake")
        case 4: // 소나기
            return UIImage(systemName: "cloud.bolt.rain")
        case 5: // 빗방울
            return UIImage(systemName: "cloud.drizzle")
        case 6: // 빗방울눈날림
            return UIImage(systemName: "cloud.sleet")
        case 7: // 눈날림
            return UIImage(systemName: "cloud.snow")
        default:
            // 강수 없음 → 하늘 상태로 판별
            switch sky {
            case 1: return UIImage(systemName: "sun.max")
            case 3: return UIImage(systemName: "cloud.sun")
            case 4: return UIImage(systemName: "smoke")
            default: return UIImage(systemName: "sun.max")
            }
        }
    }
}
