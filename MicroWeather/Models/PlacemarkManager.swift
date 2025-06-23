//
//  AddressManager.swift
//  MicroWeather
//
//  Created by 김정원 on 5/15/25.
//

import UIKit
import CoreLocation

struct Placemark: Codable, Equatable {
    let address: String 
    let nx, ny: String
    let lon, lat: Double
    let code: String
    var isBookmark: Bool
}

class PlacemarkManager {
    static let shared = PlacemarkManager()
    private init() { }
    
    private let xyConverter = XYConverter.shared
    private let kakaoAPIManager = KakaoAPIManager.shared
    private let locationManager = LocationManager.shared
    
    var currentPlacemark: Placemark? {
        didSet {
            NotificationCenter.default.post(name: .placemarkDidChange, object: nil, userInfo: ["newPlacemark": currentPlacemark!])
        }
    }
    
    private let recentKey = "recentPlacemarks"
    private let bookmarkKey = "bookmarkPlacemarks"
    private let maxRecent = 10

    // 저장·불러오기 공통 로직
    private func loadList(forKey key: String) -> [Placemark] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let list = try? JSONDecoder().decode([Placemark].self, from: data)
        else { return [] }
        return list
    }
    private func saveList(_ list: [Placemark], forKey key: String) {
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // 최근 검색
    func addRecent(_ pm: Placemark) {
        var list = loadList(forKey: recentKey)
        list.removeAll { $0.code == pm.code }
        list.insert(pm, at: 0)
        if list.count > maxRecent { list.removeLast() }
        saveList(list, forKey: recentKey)
    }
    func getRecents() -> [Placemark] {
        loadList(forKey: recentKey)
    }

    // 즐겨찾기
    func toggleBookmark(_ pm: Placemark) {
        var bookmark_list = loadList(forKey: bookmarkKey)
        
        if pm.isBookmark {
            bookmark_list.append(pm)
        } else {
            bookmark_list.removeAll() { $0.code == pm.code }
        }
        saveList(bookmark_list, forKey: bookmarkKey)
        
        var recent_list = loadList(forKey: recentKey)
        if let idx = recent_list.firstIndex(where: { $0.code == pm.code }) {
            recent_list[idx].isBookmark = pm.isBookmark
            saveList(recent_list, forKey: recentKey)
        }
    }
    func getBookmarks() -> [Placemark] {
        loadList(forKey: bookmarkKey)
    }
    func isBookmark(code: String) -> Bool {
        var bookmark_list = loadList(forKey: bookmarkKey)
        bookmark_list = bookmark_list.filter({ $0.code == code })
        return !bookmark_list.isEmpty
    }
    
    //SearchViewController에서 실행
    func convertAddressToPlacemark(address: Address, completion: @escaping (Placemark?) -> Void) {
        kakaoAPIManager.fetchCoordinate(keyword: address.full_address) { [weak self] data in
            guard let self = self, let data = data else {
                completion(nil)
                return
            }
            
            let lon = Double(data.x)!, lat = Double(data.y)!
            let xy = xyConverter.calculateCoordinate(lon: lon, lat: lat)
            let isBookmark = self.isBookmark(code: data.address.h_code)
            let placemark = Placemark(address: address.address, nx: String(xy.x), ny: String(xy.y), lon: lon, lat: lat, code: data.address.h_code, isBookmark: isBookmark)
            
            completion(placemark)
        }
    }
    
    func convertLocationToPlacemark(location: CLLocation, completion: @escaping (Placemark?) -> Void) {
        let (longitude, latitude) = (Double(location.coordinate.longitude), Double(location.coordinate.latitude))
        let coordinate = xyConverter.calculateCoordinate(lon: longitude, lat: latitude)
        
        kakaoAPIManager.fetchAddress(location: location) { [weak self] datas in
            guard let self = self, let datas = datas else {
                completion(nil)
                return
            }
            
            guard let data = datas.filter({ $0.region_type == "H" }).first else {
                completion(nil)
                return
            }

            let isBookmark = self.isBookmark(code: data.code!)
            let placemark = Placemark(address: data.address, nx: String(coordinate.x), ny: String(coordinate.y), lon: longitude, lat: latitude, code: data.code!, isBookmark: isBookmark)
            
            completion(placemark)
        }
    }
    
    func loadPlacemarkOfCurrentLocation(completion: @escaping (Placemark?) -> Void) {
        locationManager.requestCurrentLocation { [weak self] location in
            guard let self = self, let location = location else {
                completion(nil)
                return
            }
  
            self.convertLocationToPlacemark(location: location) { pm in
                completion(pm)
            }
        }
    }
}
