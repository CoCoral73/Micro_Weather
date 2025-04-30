//
//  LocationManager.swift
//  MicroWeather
//
//  Created by 김정원 on 4/29/25.
//

import UIKit
import CoreLocation
import Contacts

struct XYLocation: Codable {
    let administrativeArea: String
    let locality: String
    let subLocality: String
    let nx: Int
    let ny: Int
    
    var address: String {
        return "\(administrativeArea)\(locality)\(subLocality)"
    }
}

final class LocationManager: NSObject {
    static let shared = LocationManager()
    
    private let manager = CLLocationManager()
    private var completionHandler: [(CLLocation?) -> Void] = []
    
    private(set) var allLocations: [XYLocation] = []
    private let coordinateMap: [String:(String, String)]
    
    private override init() {
        let loaded: [XYLocation]
        if let url = Bundle.main.url(forResource: "CoordinateData", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let arr = try? JSONDecoder().decode([XYLocation].self, from: data) {
            loaded = arr
        } else {
            loaded = []
        }
        self.allLocations = loaded
        
        var map = [String:(String, String)]()
        allLocations.forEach { loc in
            map[loc.address] = ("\(loc.nx)", "\(loc.ny)")
        }
        coordinateMap = map
        
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    /// 위치 권한 요청과 최신 위치를 한 번에 얻어오는 메서드
    func requestCurrentLocation(completion: @escaping (CLLocation?) -> Void) {
        // 1) 완료 핸들러 저장
        completionHandler.append(completion)
        
        // 2) 권한 상태 체크
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default: //거부
            fulfillAll(with: nil)
        }
    }
    
    func convertLocationToCoordinate(loc: CLLocation, completion: @escaping ((nx: String, ny: String)?) -> Void) {
        print(#function, loc)
        reverseGeocode(location: loc) { [weak self] addr in
            guard let self = self else { return }
            if let addr = addr {
                print("address:", addr)
                completion(self.coordinateMap[addr])
            } else {
                print("주소 변환에 실패했습니다.")
            }
        }
    }
    
    func reverseGeocode(location: CLLocation, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil, let pm = placemarks?.first else {
                print("역지오코딩 실패:", error?.localizedDescription ?? "Unknown")
                completion(nil)
                return
            }
            
            if let postal = pm.postalAddress {
                // postal.state   : 시도          (서울특별시)
                // postal.city    : 구/군/시      (강남구)
                // postal.subLocality: 동/읍/면 (역삼동)
                
                let parts = [postal.state,
                             postal.city,
                             postal.subLocality]
                    .filter { !$0.isEmpty }
                
                completion(parts.joined(separator: " "))
                return
            }
            
            // fallback: 기존 방식
            let province = pm.administrativeArea        // ex. "서울특별시"
            let district = pm.locality                  // ex. "동작구" 혹은
                                                        //     서버에 따라 city 레벨이 달라짐
            let neighborhood = pm.subLocality            // ex. "사당동"
            
            let address = [province, district, neighborhood].compactMap { $0 }.joined(separator: " ")
            completion(address)
        }
    }
    
    private func fulfillAll(with location: CLLocation?) {
        completionHandler.forEach { $0(location) }
        completionHandler.removeAll()
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ mgr: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            mgr.requestLocation()
        } else if status == .denied || status == .restricted {
            fulfillAll(with: nil)
        }
    }
    
    func locationManager(_ mgr: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 가장 최근 위치 전달
        fulfillAll(with: locations.last)
    }
    
    func locationManager(_ mgr: CLLocationManager, didFailWithError error: Error) {
        // 실패 시에도 nil 반환
        fulfillAll(with: nil)
    }
}
