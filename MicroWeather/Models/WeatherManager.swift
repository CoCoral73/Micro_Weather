//
//  WeatherManager.swift
//  MicroWeather
//
//  Created by 김정원 on 4/21/25.
//

import UIKit

final class WeatherManager {
    static let shared = WeatherManager()
    private init() {
        
    }
    
    private let apiManager = WeatherAPIManager.shared
    
    func calculateBaseDateTime(for apiType: WeatherAPIType, now: Date = Date(), calendar: Calendar = Calendar.current) -> (baseDate: String, baseTime: String, updatedBase: String, lastUpdated: String) {
        // 1) 포맷터 준비
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.dateFormat = "HHmm"
        
        // 2) basetime 후보 및 valid 계산용
        var candidateTimes: [Date] = []
        
        switch apiType {
        case .ultraSrtNcst:
            // 매시 :00
            var c = calendar.dateComponents([.year, .month, .day, .hour], from: now)
            c.minute = 0
            let floor = calendar.date(from: c)!
            let valid = calendar.date(byAdding: .minute, value: 10, to: floor)!
            let baseDT = now < valid ? calendar.date(byAdding: .hour, value: -1, to: floor)! : floor
            candidateTimes = [baseDT]

        case .ultraSrtFcst:
            // 매시 :30
            var c = calendar.dateComponents([.year, .month, .day, .hour], from: now)
            c.minute = 30
            let floor = calendar.date(from: c)!
            let valid = calendar.date(byAdding: .minute, value: 15, to: floor)!
            let baseDT = now < valid ? calendar.date(byAdding: .hour, value: -1, to: floor)! : floor
            candidateTimes = [baseDT]
            
        case .srtFcst:
            // 기준 시각 목록
            let hours = [2,5,8,11,14,17,20,23]
            // 오늘 날짜의 각 후보 시각
            candidateTimes = hours.compactMap { h in
                var comps = calendar.dateComponents([.year, .month, .day], from: now)
                comps.hour = h; comps.minute = 0
                return calendar.date(from: comps)
            }
            // validTime = candidate + 10분
            let valids = candidateTimes.map {
                calendar.date(byAdding: .minute, value: 10, to: $0)!
            }
            // valid ≤ now 인 것 중 최신 것 선택
            let past = zip(candidateTimes, valids).filter { _, validTime in validTime <= now }
            
            if let (chosen, _) = past.max(by: { $0.0 < $1.0 }) {
                candidateTimes = [chosen]
            } else {
                // 아직 첫 타임도 유효 전 → 어제 23:00
                let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
                var comps = calendar.dateComponents([.year, .month, .day], from: yesterday)
                comps.hour = 23; comps.minute = 0
                let dt = calendar.date(from: comps)!
                candidateTimes = [dt]
            }
        }
        
        // 3) 최종 baseDateTime
        let baseDT = candidateTimes.first!
        let baseDate = dateFormatter.string(from: baseDT)
        let baseTime = timeFormatter.string(from: baseDT)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        let updatedBase: String
        switch apiType {
        case .ultraSrtNcst:
            updatedBase = calculateUpdatedBase(now: now, calendar: calendar)
        case .ultraSrtFcst, .srtFcst:
            updatedBase = dateFormatter.string(from: baseDT)
        }
        
        let lastUpdated = dateFormatter.string(from: now)
        return (baseDate, baseTime, updatedBase, lastUpdated)
    }
    
    private func calculateUpdatedBase(now: Date, calendar: Calendar) -> String {
        var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let minute = comps.minute!

        let displayMinute: Int
        if minute < 10 {
            displayMinute = 50
            comps.hour! -= 1
        } else {
            displayMinute = ((minute - 10) / 10) * 10
        }

        comps.minute = displayMinute
        comps.second = 0
        
        let updatedBase = calendar.date(from: comps)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: updatedBase)
    }
    
    func fetchUltraShortTermNowcast(parameters: RequestParameters, completionHandler: @escaping (Result<NowcastValue, Error>) -> Void) {
        apiManager.fetchWeatherData(apiType: .ultraSrtNcst, parameters: parameters) { result in
            switch result {
            case .success(let model):
                guard let obs = model as? UltraShortTermNowcast else {
                    completionHandler(.failure(NSError(domain: "WeatherManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "타입캐스팅 실패"])))
                    return
                }
                
                var value: NowcastValue = NowcastValue()
                obs.response.body.items.item.forEach { item in
                    switch item.category {
                    case "T1H":
                        value.temp = item.obsrValue
                    case "RN1":
                        value.rain = item.obsrValue
                    case "REH":
                        value.hum = item.obsrValue
                    case "VEC":
                        value.vec = Double(item.obsrValue)
                    case "WSD":
                        value.wind = item.obsrValue
                    default:
                        break
                    }
                }
                
                completionHandler(.success(value))
            case .failure(let error):
                print(error.description)
                completionHandler(.failure(error))
            }
        }
    }
    
    func fetchUltraShortTermFcst(parameters: RequestParameters, completionHandler: @escaping (Result<[ForecastValue], Error>) -> Void) {
        apiManager.fetchWeatherData(apiType: .ultraSrtFcst, parameters: parameters) { result in
            switch result {
            case .success(let model):
                guard let obs = model as? UltraShortTermForecast else {
                    completionHandler(.failure(NSError(domain: "WeatherManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "타입캐스팅 실패"])))
                    return
                }
                
                var values: [String: ForecastValue] = [:]
                
                let timeFormatter = DateFormatter()
                timeFormatter.locale = Locale(identifier: "ko_KR")
                timeFormatter.dateFormat = "HH"
                let current_hour = timeFormatter.string(from: Date())
                
                obs.response.body.items.item.forEach { item in
                    if item.fcstTime.prefix(2) != current_hour {
                        let time = "\(item.fcstDate)\(item.fcstTime)"
                        if ["T1H", "PTY", "SKY"].contains(item.category) {
                            if values[time] == nil {
                                values.updateValue(ForecastValue(), forKey: time)
                                values[time]?.fcstdate = item.fcstDate
                                values[time]?.fcsttime = item.fcstTime
                            }
                        }
                        
                        switch item.category {
                        case "T1H":
                            values[time]!.temp = item.fcstValue
                        case "PTY":
                            values[time]!.pty = Int(item.fcstValue)
                        case "SKY":
                            values[time]!.sky = Int(item.fcstValue)
                        default:
                            break
                        }
                    }
                }
                
                let sortedValues = values.values.sorted { value1, value2 in
                    let datetime1 = "\(value1.fcstdate ?? "")\(value1.fcsttime ?? "")"
                    let datetime2 = "\(value2.fcstdate ?? "")\(value2.fcsttime ?? "")"
                    return datetime1 < datetime2
                }
                
                completionHandler(.success([ForecastValue](sortedValues)))
            case .failure(let error):
                print(error.description)
                completionHandler(.failure(error))
            }
        }
    }
    
    func fetchShortTermFcst(parameters: RequestParameters, completionHandler: @escaping () -> Void) {
        apiManager.fetchWeatherData(apiType: .srtFcst, parameters: parameters) { result in
            switch result {
            case .success(let model):
                completionHandler()
            case .failure(let error):
                print(error.description)
                completionHandler()
            }
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
