//
//  Main2ViewController.swift
//  MicroWeather
//
//  Created by 김정원 on 5/26/25.
//

import UIKit

class Main2ViewController: UIViewController {

    @IBOutlet weak var basetimeLabel: UILabel!
    @IBOutlet weak var updatedTimeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var expandedSection: Set<Int> = []
    
    var forecasts: (values: [(String, [ForecastValue])], basetime: String, updatedTime: String) = ([], "", "") {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 50
        
        tableView.tableFooterView = makeTableFooter()
    }
    
    func updateUI() {
        guard !forecasts.values.isEmpty else {
            basetimeLabel.text = "데이터 불러오기 실패"
            updatedTimeLabel.text = "업데이트를 다시 시도해주세요"
            tableView.reloadData()
            return
        }
        
        basetimeLabel.text = forecasts.basetime
        updatedTimeLabel.text = forecasts.updatedTime
        
        tableView.reloadData()
    }
}

extension Main2ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return forecasts.values.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let forecasts = forecasts.values
        
        let count = forecasts[section].1.count
        if count < 5 || expandedSection.contains(section) {
            return count
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let forecasts = forecasts.values
        
        for st in (0..<forecasts.count) {
            if section == st {
                return forecasts[st].1[0].dateString
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 40 : 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.forecastCell, for: indexPath) as! ForecastCell
        let forecasts = forecasts.values
        
        let total = forecasts.count
        (0..<total).forEach {
            if indexPath.section == $0 {
                cell.forecast = forecasts[$0].1[indexPath.row]
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let forecasts = forecasts.values
        // 해당 섹션 데이터 개수가 기준 초과인지
        let count = forecasts[section].1.count
        guard count > 5 else {
            return nil
        }

        // 버튼 생성 (접기/더보기 토글 하나의 메서드로 통일)
        let btn = UIButton(type: .system)
        btn.tag = section
        btn.setTitle(
          expandedSection.contains(section) ? "닫기" : "더보기",
          for: .normal
        )
        btn.addTarget(self, action: #selector(toggleSection), for: .touchUpInside)
        return btn
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let forecasts = forecasts.values
        
        let count = forecasts[section].1.count
        return count > 5 ? 44 : 0  // 버튼 높이에 맞춰서
    }
    
    @objc func toggleSection(_ sender: UIButton) {
        let section = sender.tag
        
        if expandedSection.contains(section) {
            expandedSection.remove(sender.tag)
        } else {
            expandedSection.insert(section)
        }
        
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        tableView.endUpdates()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            // (A) 섹션 헤더를 화면 상단에 붙이고 싶으면
            // 1) 섹션 헤더의 y 위치 계산
            let headerRect = self.tableView.rectForHeader(inSection: section)
            let desiredOffsetY = headerRect.origin.y - self.tableView.contentInset.top

            // 2) 스크롤 가능한 최대 y 오프셋 계산
            let maxOffsetY = max(
                0,
                self.tableView.contentSize.height + self.tableView.contentInset.bottom
                - self.tableView.bounds.height
            )

            // 3) 0 ~ maxOffsetY 사이로 클램프
            let clampedOffsetY = min(max(desiredOffsetY, 0), maxOffsetY)

            // 4) 스크롤 이동
            self.tableView.setContentOffset(
                CGPoint(x: 0, y: clampedOffsetY),
                animated: true
            )
        }
        
    }
    
    func makeTableFooter() -> UIView {
        // 1) Footer 컨테이너
        let footer = UIView()
        footer.backgroundColor = .clear
        
        // 2) 출처 레이블
        let creditLabel = UILabel()
        creditLabel.text = "출처: 기상청, “단기예보조회” 데이터 (CC BY 4.0)\n출처: 공공데이터포털 (https://www.data.go.kr)"
        creditLabel.font = .systemFont(ofSize: 11)
        creditLabel.numberOfLines = 0
        creditLabel.textAlignment = .center
        creditLabel.translatesAutoresizingMaskIntoConstraints = false
        footer.addSubview(creditLabel)
        
        // 3) Auto Layout 제약
        NSLayoutConstraint.activate([
            // 좌우 16pt 패딩
            creditLabel.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 16),
            creditLabel.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -16),
            // 위쪽 8pt, 아래쪽 8pt
            creditLabel.topAnchor.constraint(equalTo: footer.topAnchor, constant: 8),
            creditLabel.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -8),
        ])
        
        // 4) 높이 계산
        footer.layoutIfNeeded()
        let labelSize = creditLabel.sizeThatFits(CGSize(
            width: UIScreen.main.bounds.width - 32, // 좌우 패딩 제외
            height: CGFloat.greatestFiniteMagnitude
        ))
        let footerHeight = labelSize.height + 16 // 상하 패딩 포함
        footer.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: footerHeight
        )
        
        return footer
    }
}
