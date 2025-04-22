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
    
    func fetchUltraShortTermObsr(completionHandler: @escaping (Result<USTOValue, Error>) -> Void) {
        apiManager.fetchWeatherData(apiType: .ultraSrtNcst) { result in
            switch result {
            case .success(let model):
                guard let obs = model as? UltraShortTermObservations else {
                    completionHandler(.failure(NSError(
                        domain: "WeatherManager",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "타입캐스팅 실패"]
                    )))
                    return
                }
                
                var value: USTOValue = USTOValue()
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
                print(error.localizedDescription)
                completionHandler(.failure(error))
            }
        }
    }
    
    func fetchUltraShortTermFcst(completionHandler: @escaping () -> Void) {
        apiManager.fetchWeatherData(apiType: .ultraSrtFcst) { result in
            switch result {
            case .success(let model):
                completionHandler()
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler()
            }
        }
    }
    
    func fetchShortTermFcst(completionHandler: @escaping () -> Void) {
        apiManager.fetchWeatherData(apiType: .vilageFcst) { result in
            switch result {
            case .success(let model):
                completionHandler()
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler()
            }
        }
    }
}
