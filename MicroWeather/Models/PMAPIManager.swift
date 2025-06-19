//
//  PMAPIManager.swift
//  MicroWeather
//
//  Created by 김정원 on 5/29/25.
//

import UIKit
import CoreLocation

class PMAPIManager {
    static let shared = PMAPIManager()
    private let keyManager = ServiceKeyManager.shared
    
    private init() {
        self.serviceKey = keyManager.getServiceKey()
    }
    
    private let serviceKey: String
    
    func fetchStationName(location: (lon: Double, lat: Double), completionHandler: @escaping (Result<String, FetchError>) -> Void) {
        let xy = TransverseMercator.project(lat: location.lat, lon: location.lon)
        var components = URLComponents(string: PMAPIType.nearStation.endpoint)!
        components.queryItems = [
            URLQueryItem(name: "returnType", value: "json"),
            URLQueryItem(name: "tmX", value: String(xy.0)),
            URLQueryItem(name: "tmY", value: String(xy.1))
        ]
        
        let rest = components.percentEncodedQuery.map { "&\($0)" } ?? ""
        components.percentEncodedQuery = "serviceKey=\(serviceKey)" + rest
        
        guard let url = components.url else { return }
        
        performRequest(with: url, apiType: .nearStation) { result in
            switch result {
            case .success(let item):
                let item = (item as! Station_Response).response.body.items
                let target = item.min { $0.tm < $1.tm }
                
                if target == nil {
                    completionHandler(.failure(.castingError))
                    return
                }
                
                completionHandler(.success(target!.stationName))
                
            case .failure(let error):
                print(error.description)
                completionHandler(.failure(error))
            }
        }
    }
    
    func fetchMeasurement(stationName: String, completionHandler: @escaping (Result<Measurement_Response.Item, FetchError>) -> Void) {
        var components = URLComponents(string: PMAPIType.measurement.endpoint)!
        components.queryItems = [
            URLQueryItem(name: "returnType", value: "json"),
            URLQueryItem(name: "numOfRows", value: "100"),
            URLQueryItem(name: "pageNo", value: "1"),
            URLQueryItem(name: "stationName", value: stationName),
            URLQueryItem(name: "dataTerm", value: "DAILY"),
            URLQueryItem(name: "ver", value: "1.0")
        ]
        
        let rest = components.percentEncodedQuery.map { "&\($0)" } ?? ""
        components.percentEncodedQuery = "serviceKey=\(serviceKey)" + rest
        
        guard let url = components.url else { return }
        
        performRequest(with: url, apiType: .measurement) { result in
            switch result {
            case .success(let item):
                let item = (item as! Measurement_Response).response.body.items
                let target = item.first
                
                if target == nil {
                    completionHandler(.failure(.castingError))
                    return
                }
                
                completionHandler(.success(target!))
                
            case .failure(let error):
                print(error.description)
                completionHandler(.failure(error))
            }
        }
    }
    
    private func performRequest(with url: URL, apiType: PMAPIType, completionHandler: @escaping (Result<Any, FetchError>) -> Void) {
        
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
