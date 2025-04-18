//
//  WeatherAPIModels.swift
//  MicroWeather
//
//  Created by 김정원 on 4/18/25.
//

import UIKit

// MARK: - UltraShortTermObservations
struct UltraShortTermObservations {
    let response: Response
    
    // MARK: - Response
    struct Response {
        let header: Header
        let body: Body
    }

    // MARK: - Body
    struct Body {
        let dataType: String
        let items: Items
        let pageNo, numOfRows, totalCount: Int
    }

    // MARK: - Items
    struct Items {
        let item: [Item]
    }

    // MARK: - Item
    struct Item {
        let baseDate, baseTime, category: String
        let nx, ny: Int
        let obsrValue: String
    }

    // MARK: - Header
    struct Header {
        let resultCode, resultMsg: String
    }
}

// MARK: - UltraShortTermForecast
struct UltraShortTermForecast {
    let response: Response
    
    // MARK: - Response
    struct Response {
        let header: Header
        let body: Body
    }

    // MARK: - Body
    struct Body {
        let dataType: String
        let items: Items
        let pageNo, numOfRows, totalCount: Int
    }

    // MARK: - Items
    struct Items {
        let item: [Item]
    }

    // MARK: - Item
    struct Item {
        let baseDate, baseTime, category, fcstDate: String
        let fcstTime, fcstValue: String
        let nx, ny: Int
    }

    // MARK: - Header
    struct Header {
        let resultCode, resultMsg: String
    }
}

// MARK: - ShortTermForecast
struct ShortTermForecast {
    let response: Response
    
    // MARK: - Response
    struct Response {
        let header: Header
        let body: Body
    }

    // MARK: - Body
    struct Body {
        let dataType: String
        let items: Items
        let pageNo, numOfRows, totalCount: Int
    }

    // MARK: - Items
    struct Items {
        let item: [Item]
    }

    // MARK: - Item
    struct Item {
        let baseDate, baseTime: String
        let category: Category
        let fcstDate, fcstTime, fcstValue: String
        let nx, ny: Int
    }

    // MARK: - Header
    struct Header {
        let resultCode, resultMsg: String
    }
}

// MARK: - ForecastVersion
struct ForecastVersion {
    let response: Response
    
    // MARK: - Response
    struct Response {
        let header: Header
        let body: Body
    }

    // MARK: - Body
    struct Body {
        let dataType: String
        let items: Items
        let pageNo, numOfRows, totalCount: Int
    }

    // MARK: - Items
    struct Items {
        let item: [Item]
    }

    // MARK: - Item
    struct Item {
        let filetype, version: String
    }

    // MARK: - Header
    struct Header {
        let resultCode, resultMsg: String
    }
}
