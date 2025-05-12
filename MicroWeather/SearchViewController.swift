//
//  SearchViewController.swift
//  MicroWeather
//
//  Created by 김정원 on 5/12/25.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    let bookmarks: [String] = ["동작구 사당4동", "성북구 길음동", "서초구 서초2동"]
    let searched: [String] = ["달서구 진천동", "달서구 도원동", "달서구 상인동"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = 50

    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return makeTableHeader("즐겨찾기")
        } else {
            return makeTableHeader("최근 검색한 주소")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return bookmarks.count
        } else {
            return searched.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.searchCell, for: indexPath) as! SearchTableViewCell
        
        if indexPath.section == 0 {
            cell.addressLabel.text = bookmarks[indexPath.row]
        } else {
            cell.addressLabel.text = searched[indexPath.row]
        }
        
        return cell
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
            titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 22),
            
            line.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            line.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            line.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20),
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
