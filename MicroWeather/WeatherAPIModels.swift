//
//  WeatherAPIModels.swift
//  MicroWeather
//
//  Created by 김정원 on 4/18/25.
//

import UIKit

struct RequestParameters {
    let basedate, basetime: String
    let nx, ny: String
}

// MARK: - UltraShortTermNowcast
struct UltraShortTermNowcast: Codable {
    let response: Response
    
    // MARK: - Response
    struct Response: Codable {
        let header: Header
        let body: Body
    }

    // MARK: - Body
    struct Body: Codable {
        let dataType: String
        let items: Items
        let pageNo, numOfRows, totalCount: Int
    }

    // MARK: - Items
    struct Items: Codable {
        let item: [Item]
    }
    
    // MARK: - Item
    struct Item: Codable {
        let baseDate, baseTime, category: String
        let nx, ny: Int
        let obsrValue: String
    }
    
    // MARK: - Header
    struct Header: Codable {
        let resultCode, resultMsg: String
    }
}

struct NowcastValue {
    var temp, hum, rain: String?
    var vec: Double?
    var wind: String?
    
    var vecString: String {
        return CompassDirection16(from: vec ?? 0).description
    }
}


// MARK: - UltraShortTermForecast
struct UltraShortTermForecast: Codable {
    let response: Response
    
    // MARK: - Response
    struct Response: Codable {
        let header: Header
        let body: Body
    }

    // MARK: - Body
    struct Body: Codable {
        let dataType: String
        let items: Items
        let pageNo, numOfRows, totalCount: Int
    }

    // MARK: - Items
    struct Items: Codable {
        let item: [Item]
    }

    // MARK: - Item
    struct Item: Codable {
        let baseDate, baseTime, category: String
        let fcstDate, fcstTime, fcstValue: String
        let nx, ny: Int
    }

    // MARK: - Header
    struct Header: Codable {
        let resultCode, resultMsg: String
    }
}

// MARK: - ShortTermForecast
struct ShortTermForecast: Codable {
    let response: Response
    
    // MARK: - Response
    struct Response: Codable {
        let header: Header
        let body: Body
    }

    // MARK: - Body
    struct Body: Codable {
        let dataType: String
        let items: Items
        let pageNo, numOfRows, totalCount: Int
    }

    // MARK: - Items
    struct Items: Codable {
        let item: [Item]
    }

    // MARK: - Item
    struct Item: Codable {
        let baseDate, baseTime, category: String
        let fcstDate, fcstTime, fcstValue: String
        let nx, ny: Int
    }

    // MARK: - Header
    struct Header: Codable {
        let resultCode, resultMsg: String
    }
}

struct ForecastValue {
    var fcstdate, fcsttime: String?
    var temp: String?
}


// MARK: - ForecastVersion
struct ForecastVersion: Codable {
    let response: Response
    
    // MARK: - Response
    struct Response: Codable {
        let header: Header
        let body: Body
    }

    // MARK: - Body
    struct Body: Codable {
        let dataType: String
        let items: Items
        let pageNo, numOfRows, totalCount: Int
    }

    // MARK: - Items
    struct Items: Codable {
        let item: [Item]
    }

    // MARK: - Item
    struct Item: Codable {
        let filetype, version: String
    }

    // MARK: - Header
    struct Header: Codable {
        let resultCode, resultMsg: String
    }
}
