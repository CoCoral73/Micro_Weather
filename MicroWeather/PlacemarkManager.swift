//
//  AddressManager.swift
//  MicroWeather
//
//  Created by 김정원 on 5/15/25.
//

import UIKit

struct Placemark: Codable, Equatable {
    let address: String?
    let nx, ny: String
    var isBookmark: Bool
}

class PlacemarkManager {
    static let shared = PlacemarkManager()
    private init() { }
    
    private let recentKey = "recentPlacemarks"
    private let bookmarkKey = "bookmarkPlacemarks"
    private let maxRecent = 5

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
        list.removeAll { $0 == pm }
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
            bookmark_list.removeAll() { $0.address == pm.address }
        }
        saveList(bookmark_list, forKey: bookmarkKey)
        
        var recent_list = loadList(forKey: recentKey)
        if let idx = recent_list.firstIndex(where: { $0.address == pm.address }) {
            recent_list[idx].isBookmark = pm.isBookmark
            saveList(recent_list, forKey: recentKey)
        }
    }
    func getBookmarks() -> [Placemark] {
        loadList(forKey: bookmarkKey)
    }
    
}
