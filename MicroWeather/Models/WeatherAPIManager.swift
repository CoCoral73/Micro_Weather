//
//  WeatherAPIManager.swift
//  MicroWeather
//
//  Created by 김정원 on 4/18/25.
//

import UIKit



final class WeatherAPIManager {
    static let shared = WeatherAPIManager()
    private let keyManager = ServiceKeyManager.shared
    
    private init() {
        self.serviceKey = keyManager.getServiceKey()
    }
    
    private let serviceKey: String
    
    func fetchWeatherData(apiType: WeatherAPIType, parameters: RequestParameters, completionHandler: @escaping (Result<Any, FetchError>) -> Void) {
        
        var components = URLComponents(string: apiType.endpoint)!
        
        components.queryItems = [
            URLQueryItem(name: "numOfRows", value: "1000"),
            URLQueryItem(name: "pageNo", value: "1"),
            URLQueryItem(name: "dataType", value: "JSON"),
            URLQueryItem(name: "base_date", value: parameters.basedate),
            URLQueryItem(name: "base_time", value: parameters.basetime),
            URLQueryItem(name: "nx", value: parameters.nx),
            URLQueryItem(name: "ny", value: parameters.ny)
        ]

        let rest = components.percentEncodedQuery.map { "&\($0)" } ?? ""
        components.percentEncodedQuery = "serviceKey=\(serviceKey)" + rest
        
        guard let url = components.url else { return }

        performRequest(with: url, apiType: apiType) { result in
            completionHandler(result)
        }
    }
    
    private func performRequest(with url: URL, apiType: WeatherAPIType, completionHandler: @escaping (Result<Any, FetchError>) -> Void) {
        
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
}
