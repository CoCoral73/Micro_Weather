//
//  Main1ViewController.swift
//  MicroWeather
//
//  Created by 김정원 on 5/26/25.
//

import UIKit

class Main1ViewController: UIViewController {

    var headerView: Main1HeaderView?
    @IBOutlet weak var tableView: UITableView!
    
    var nowcast: (value: NowcastValue, basetime: String, updatedTime: String)? {
        didSet {
            updateNowcastUI()
        }
    }
    var forecasts: (values: [ForecastValue], basetime: String) = ([], "") {
        didSet {
            updateForecastUI()
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
        
        let headerNib = UINib(nibName: "Main1HeaderView", bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "headerView")
        headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView") as? Main1HeaderView
        
        tableView.tableFooterView = makeTableFooter()
    }
    
    func updateNowcastUI() {
        guard let headerView = headerView else { return }
        guard let nowcast = nowcast else {
            headerView.tempLabel.text = "--°"
            headerView.feelsLikeLabel.text = "체감 --°"
            headerView.humLabel.text = "--%"
            headerView.rainLabel.text = "--mm"
            headerView.vectorLabel.text = "풍향"
            headerView.windLabel.text = "--m/s"
            headerView.basetimeLabel.text = "데이터 불러오기 실패"
            headerView.updatetimeLabel.text = "업데이트를 다시 시도해주세요"
            return
        }
        
        headerView.tempLabel.text = "\(nowcast.value.temp ?? "--")°"
        headerView.feelsLikeLabel.text = "체감 \(nowcast.value.feelsLike)°"
        headerView.humLabel.text = "\(nowcast.value.hum ?? "--")%"
        headerView.rainLabel.text = "\(nowcast.value.rain ?? "--")mm"
        headerView.vectorLabel.text = "\(nowcast.value.vecString)풍"
        headerView.windLabel.text = "\(nowcast.value.wind ?? "--")m/s"
        headerView.basetimeLabel.text = "\(nowcast.basetime)"
        headerView.updatetimeLabel.text = "\(nowcast.updatedTime)"
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
    }
    
    func updateForecastUI() {
        guard let headerView = headerView else { return }
        guard !forecasts.values.isEmpty else {
            headerView.fcstBasetimeLabel.text = "데이터 불러오기 실패"
            tableView.reloadData()
            return
        }
        
        headerView.fcstBasetimeLabel.text = "\(forecasts.basetime) 발표"
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let header = headerView else { return }

        header.setNeedsLayout()
        header.layoutIfNeeded()

        let targetSize = CGSize(
            width: tableView.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let fittedSize = header.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        header.frame.size = fittedSize
        tableView.tableHeaderView = header
    }
}

extension Main1ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.forecastCell, for: indexPath) as! ForecastCell
        
        cell.forecast = forecasts.values[indexPath.row]

        return cell
    }
    
    func makeTableFooter() -> UIView {
        // 1) Footer 컨테이너
        let footer = UIView()
        footer.backgroundColor = .clear
        
        // 2) 출처 레이블
        let creditLabel = UILabel()
        creditLabel.text = "출처: 기상청, “초단기실황조회”, “초단기예보조회” 데이터 (CC BY 4.0)\n출처: 공공데이터포털 (https://www.data.go.kr)"
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
