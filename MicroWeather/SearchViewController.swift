//
//  SearchViewController.swift
//  MicroWeather
//
//  Created by 김정원 on 5/12/25.
//

import UIKit

class SearchViewController: UIViewController {

    private let locationManager = LocationManager.shared
    private let placemarkManager = PlacemarkManager.shared
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var bookmarks: [Placemark] = []
    var recents: [Placemark] = []
    var searchResults: [Placemark] = []
    
    var bookmarkButtonPressed: (Placemark) -> Void = { pm in }
    var tableViewSelected: (Placemark) -> Void = { pm in }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadBookmarksAndRecents()
        setupTableView()
    }
    
    private func loadBookmarksAndRecents() {
        bookmarks = placemarkManager.getBookmarks()
        recents = placemarkManager.getRecents()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = 50
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }

}

extension SearchViewController: UISearchBarDelegate {
    private var isSearching: Bool {
        guard let text = searchBar.text else { return false }
        return !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else { return }
        locationManager.getSearchResults(keyword: keyword, completion: { [weak self] pms in
            guard let self = self, let pms = pms else { return }
            
            DispatchQueue.main.async {
                self.searchResults = pms
                self.tableView.reloadData()
            }
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            tableView.reloadData()
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !isSearching {
            if section == 0 {
                return makeTableHeader("즐겨찾기")
            } else {
                return makeTableHeader("최근 조회한 주소")
            }
        } else {
            return makeTableHeader("검색 결과")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching { return searchResults.count }
        
        if section == 0 {
            return bookmarks.count
        } else {
            return recents.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.searchCell, for: indexPath) as! SearchTableViewCell
        
        if isSearching {
            cell.placemark = searchResults[indexPath.row]
        } else {
            if indexPath.section == 0 {
                cell.placemark = bookmarks[indexPath.row]
            } else {
                cell.placemark = recents[indexPath.row]
            }
        }
        
        cell.configureUIwithData()
        
        cell.bookmarkButtonPressed = { [weak self] cell in
            guard let self = self else { return }
            guard let pm = cell.placemark else { return }
            self.bookmarks = self.placemarkManager.getBookmarks()
            self.recents = self.placemarkManager.getRecents()
            self.tableView.reloadData()
            self.bookmarkButtonPressed(pm)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected: Placemark
        
        if isSearching {
            selected = searchResults[indexPath.row]
        } else {
            if indexPath.section == 0 {
                selected = bookmarks[indexPath.row]
            } else {
                selected = recents[indexPath.row]
            }
        }
        tableViewSelected(selected)
        dismiss(animated: true)
    }
    
    func makeTableHeader(_ title: String) -> UIView {
        let header = UIView()
        header.backgroundColor = .clear
        // 프레임 높이는 나중에 tableHeaderView에 적용할 때 설정해 줍니다.
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(titleLabel)
        
        let line = UIView()
        line.backgroundColor = .black
        line.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(line)
        
        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(equalTo: header.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 2),
            
            line.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            line.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 0),
            line.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: 0),
            line.heightAnchor.constraint(equalToConstant: 2),
            
  
            line.bottomAnchor.constraint(equalTo: header.bottomAnchor)
        ])
        
        // 전체 높이를 자동으로 계산하기 (layoutIfNeeded 후)
        header.layoutIfNeeded()
        let headerHeight = line.frame.height + 8 + titleLabel.intrinsicContentSize.height + 8
        header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerHeight)
        
        return header
    }
    
}
