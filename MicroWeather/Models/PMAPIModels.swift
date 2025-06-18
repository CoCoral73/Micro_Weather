//
//  PMAPIModels.swift
//  MicroWeather
//
//  Created by 김정원 on 5/29/25.
//

import UIKit

struct TM_Response: Codable {
    let response: Response
    
    struct Response: Codable {
        let body: Body
    }
    
    struct Body: Codable {
        let items: [Item]
    }
    
    struct Item: Codable {
        let sidoName, sggName, umdName: String
        let tmX, tmY: String
    }
}

struct Station_Response: Codable {
    let response: Response
    
    struct Response: Codable {
        let body: Body
    }
    
    struct Body: Codable {
        let items: [Item]
    }
    
    struct Item: Codable {
        //let stationCode, addr: String
        let tm: Double
        let stationName: String
    }
}

struct Measurement_Response: Codable {
    let response: Response
    
    struct Response: Codable {
        let body: Body
    }
    
    struct Body: Codable {
        let items: [Item]
    }
    
    struct Item: Codable {
        let dataTime: String
        let pm10Flag, pm25Flag: String?
        let pm10Value, pm25Value: String
        let so2Flag, coFlag, o3Flag, no2Flag: String?
        let so2Value, coValue, o3Value, no2Value: String
        let khaiValue: String
    }
}
