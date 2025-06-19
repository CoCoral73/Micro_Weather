//
//  Constants.swift
//  MicroWeather
//
//  Created by 김정원 on 4/21/25.
//

import UIKit

public struct Segue {
    static let mainToSearchIdentifier = "MainToSearch"
    static let pmToSearchIdentifier = "PMToSearch"
    private init() {}
}

public struct Cell {
    static let forecastCell = "ForecastCell"
    static let searchCell = "SearchCell"
    static let searchResultCell = "SearchResultCell"
    static let pmCell = "PMCell"
    static let pmFooterCell = "PMFooterCell"
    private init() {}
}
