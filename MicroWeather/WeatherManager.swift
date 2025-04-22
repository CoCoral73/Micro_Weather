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
    
    func fetchUltraShortTermNowcast(parameters: RequestParameters, completionHandler: @escaping (Result<NowcastValue, Error>) -> Void) {
        apiManager.fetchWeatherData(apiType: .ultraSrtNcst, parameters: parameters) { result in
            switch result {
            case .success(let model):
                guard let obs = model as? UltraShortTermNowcast else {
                    completionHandler(.failure(NSError(
                        domain: "WeatherManager",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "타입캐스팅 실패"]
                    )))
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
                print(error.localizedDescription)
                completionHandler(.failure(error))
            }
        }
    }
    
    func fetchUltraShortTermFcst(parameters: RequestParameters, completionHandler: @escaping () -> Void) {
        apiManager.fetchWeatherData(apiType: .ultraSrtFcst, parameters: parameters) { result in
            switch result {
            case .success(let model):
                completionHandler()
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler()
            }
        }
    }
    
    func fetchShortTermFcst(parameters: RequestParameters, completionHandler: @escaping () -> Void) {
        apiManager.fetchWeatherData(apiType: .srtFcst, parameters: parameters) { result in
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
