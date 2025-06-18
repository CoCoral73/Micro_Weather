//
//  PMModel.swift
//  MicroWeather
//
//  Created by 김정원 on 6/9/25.
//

import UIKit

enum PMDataType {
    case pm10
    case pm25
    case so2
    case co
    case o3
    case no2
}

struct PMValue {
    let type: PMDataType
    var titleString: String {
        switch self.type {
        case .pm10: return "미세먼지"
        case .pm25: return "초미세먼지"
        case .so2: return "아황산가스"
        case .co: return "일산화탄소"
        case .o3: return "오존"
        case .no2: return "이산화질소"
        }
    }
    let state: String?
    var stateString: String {
        if self.state != nil { return self.state! }
        guard let value = Double(value) else { return "-" }
        
        switch self.type {
        case .pm10:
            switch value {
            case ...15: return "매우 좋음"
            case ...30: return "좋음"
            case ...40: return "양호"
            case ...50: return "보통"
            case ...75: return "나쁨"
            case ...100: return "상당히 나쁨"
            case ...150: return "매우 나쁨"
            default: return "최악"
            }
        case .pm25:
            switch value {
            case ...8: return "매우 좋음"
            case ...15: return "좋음"
            case ...20: return "양호"
            case ...25: return "보통"
            case ...37: return "나쁨"
            case ...50: return "상당히 나쁨"
            case ...75: return "매우 나쁨"
            default: return "최악"
            }
        case .so2:
            switch value {
            case ...0.01: return "매우 좋음"
            case ...0.02: return "좋음"
            case ...0.04: return "양호"
            case ...0.05: return "보통"
            case ...0.1: return "나쁨"
            case ...0.15: return "상당히 나쁨"
            case ...0.6: return "매우 나쁨"
            default: return "최악"
            }
        case .co:
            switch value {
            case ...1: return "매우 좋음"
            case ...2: return "좋음"
            case ...5.5: return "양호"
            case ...9: return "보통"
            case ...12: return "나쁨"
            case ...15: return "상당히 나쁨"
            case ...32: return "매우 나쁨"
            default: return "최악"
            }
        case .o3:
            switch value {
            case ...0.02: return "매우 좋음"
            case ...0.03: return "좋음"
            case ...0.06: return "양호"
            case ...0.09: return "보통"
            case ...0.12: return "나쁨"
            case ...0.15: return "상당히 나쁨"
            case ...0.38: return "매우 나쁨"
            default: return "최악"
            }
        case .no2:
            switch value {
            case ...0.02: return "매우 좋음"
            case ...0.03: return "좋음"
            case ...0.05: return "양호"
            case ...0.06: return "보통"
            case ...0.13: return "나쁨"
            case ...0.2: return "상당히 나쁨"
            case ...1.1: return "매우 나쁨"
            default: return "최악"
            }
        }
    }
    let value: String
    var valueString: String {
        switch self.type {
        case .pm10, .pm25: return "\(value) ㎍/㎥"
        case .so2, .co, .o3, .no2: return "\(value) ppm"
        }
    }
}
