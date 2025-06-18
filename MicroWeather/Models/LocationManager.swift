//
//  LocationManager.swift
//  MicroWeather
//
//  Created by 김정원 on 4/29/25.
//

import UIKit
import CoreLocation

final class LocationManager: NSObject {
    static let shared = LocationManager()
    
    private let clLocationManager = CLLocationManager()
    private var completionHandlers: [(CLLocation?) -> Void] = []
    
    private override init() {
        super.init()
        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    /// 위치 권한 요청과 최신 위치를 한 번에 얻어오는 메서드
    func requestCurrentLocation(completion: @escaping (CLLocation?) -> Void) {
        // 1) 완료 핸들러 저장
        completionHandlers.append(completion)
        
        // 2) 권한 상태 체크
        switch clLocationManager.authorizationStatus {
        case .notDetermined:
            clLocationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            clLocationManager.requestLocation()
        default: //거부
            fulfillAll(with: nil)
        }
    }
    
    private func fulfillAll(with location: CLLocation?) {
        completionHandlers.forEach { $0(location) }
        completionHandlers.removeAll()
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
