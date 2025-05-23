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

// MARK: - Nowcast
struct Nowcast: Codable {
    let response: Response
    
    // MARK: - Response
    struct Response: Codable {
        let body: Body
    }

    // MARK: - Body
    struct Body: Codable {
        let items: Items
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
}

// MARK: - Forecast
struct Forecast: Codable {
    let response: Response
    
    // MARK: - Response
    struct Response: Codable {
        let body: Body
    }

    // MARK: - Body
    struct Body: Codable {
        let items: Items
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
}
