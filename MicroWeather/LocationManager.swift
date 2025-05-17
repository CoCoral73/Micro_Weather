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
    private let kakaoAPIManager = KakaoAPIManager.shared
    private let xyConverter = XYConverter.shared
    
    private let clLocationManager = CLLocationManager()
    private var completionHandlers: [(CLLocation?) -> Void] = []
    
    private let placemarkManager = PlacemarkManager.shared
    
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
    
    func convertLocationToPlacemark(location: CLLocation, completion: @escaping (Placemark?) -> Void) {
        let (longitude, latitude) = (Double(location.coordinate.longitude), Double(location.coordinate.latitude))
        let coordinate = xyConverter.calculateCoordinate(lon: longitude, lat: latitude)
        
        kakaoAPIManager.fetchAddress(location: location) { [weak self] addr in
            guard let self = self else { return }
            
            let bookmarks = self.placemarkManager.getBookmarks()
            completion(Placemark(address: addr,
                                 nx: String(coordinate.x), ny: String(coordinate.y),
                                 isBookmark: bookmarks.contains(where: { $0.address == addr })))
        }
    }
    
    func convertLocationToAddress(location: CLLocation, completion: @escaping (String?) -> Void) {
        kakaoAPIManager.fetchAddress(location: location) { addr in
            completion(addr)
        }
    }
    
    func convertLocationToCoordinate(location: CLLocation) -> (nx: String, ny: String) {
        let (longitude, latitude) = (Double(location.coordinate.longitude), Double(location.coordinate.latitude))
        let coordinate = xyConverter.calculateCoordinate(lon: longitude, lat: latitude)
        return (String(coordinate.x), String(coordinate.y))
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
