//
//  WeatherAPIManager.swift
//  MicroWeather
//
//  Created by 김정원 on 4/18/25.
//

import UIKit

enum NetworkError: Error {
    case networkingError
    case dataError
    case parseError
}

final class WeatherAPIManager {
    static let shared = WeatherAPIManager()
    private init() {
        guard let apiKey = WeatherAPIManager.loadAPIServiceKey() else {
            fatalError("🔑 API Service Key 불러오기 실패")
        }
        self.serviceKey = apiKey
    }
    
    private let serviceKey: String
    
    func fetchWeatherData(apiType: WeatherAPIType, parameters: RequestParameters, completionHandler: @escaping (Result<Any, NetworkError>) -> Void) {
        
        var components = URLComponents(string: apiType.endpoint)!
        components.percentEncodedQueryItems = [
            URLQueryItem(name: "serviceKey", value: self.serviceKey),
            URLQueryItem(name: "numOfRows", value: "100"),
            URLQueryItem(name: "pageNo", value: "1"),
            URLQueryItem(name: "dataType", value: "JSON"),
            URLQueryItem(name: "base_date", value: parameters.basedate),
            URLQueryItem(name: "base_time", value: parameters.basetime),
            URLQueryItem(name: "nx", value: parameters.nx),
            URLQueryItem(name: "ny", value: parameters.ny)
        ]
        
        guard let url = components.url else { return }

        performRequest(with: url, apiType: apiType) { result in
            completionHandler(result)
        }
    }
    
    private func performRequest(with url: URL, apiType: WeatherAPIType, completionHandler: @escaping (Result<Any, NetworkError>) -> Void) {
        
        let request = URLRequest(url: url)
        print("Request URL: \(request.url!)")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
                
            guard error == nil else {
                return completionHandler(.failure(.networkingError))
            }
            
            guard let safeData = data else {
                return completionHandler(.failure(.dataError))
            }
            
            do {
                let decodedData = try JSONDecoder().decode(apiType.modelType, from: safeData)
                
                completionHandler(.success(decodedData))
            } catch {
                completionHandler(.failure(.parseError))
            }
                
        }.resume()
    }
    
    private static func loadAPIServiceKey() -> String? {
      guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization
                        .propertyList(from: data, format: nil)
                as? [String: Any]
      else { return nil }
      return dict["WeatherAPIServiceKey"] as? String
    }
}
