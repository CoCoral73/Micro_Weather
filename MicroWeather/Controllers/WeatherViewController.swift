//
//  ViewController.swift
//  MicroWeather
//
//  Created by 김정원 on 4/18/25.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    private var headerView: WeatherHeaderView?
    
    @IBOutlet weak var tableView: UITableView!
    
    private let weatherManager = WeatherManager.shared
    private let locationManager = LocationManager.shared
    private let placemarkManager = PlacemarkManager.shared
    
    var placemark: Placemark?
    
    var ultraShortTermForcasts: [ForecastValue] = []
    var shortTermForcasts: [(String, [ForecastValue])] = []
    
    private var expandedSection: Set<Int> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableview()
        
        loadCurrentLocationWeather()
    }
    
    private func setupUI() {
        //임시
        self.tabBarItem = UITabBarItem(title: "날씨", image: UIImage(systemName: "star"), selectedImage: UIImage(systemName: "star.fill"))
    }
    
    func setupTableview() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 50
        
        let headerNib = UINib(nibName: "WeatherMainView", bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "headerView")
        headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView") as? WeatherHeaderView
        connectButtonAction()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = makeTableFooter()
    }
    
    func connectButtonAction() {
        guard let headerView = headerView else { return }
        
        headerView.currentLocationButton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
        headerView.segControl.addTarget(self, action: #selector(segControlChanged), for: .valueChanged)
        headerView.refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
    }
    
    private func loadCurrentLocationWeather() {
        LocationManager.shared.requestCurrentLocation { [weak self] location in
            guard let self = self else { return }
            guard let location = location else { return }
            
            self.locationManager.convertLocationToPlacemark(location: location) { pm in
                guard let pm = pm else { return }
                DispatchQueue.main.async {
                    self.placemark = pm
                    self.fetchWeatherAndUpdateUI()
                }
                self.placemarkManager.addRecent(pm)
            }
        }
    }
    
    private func fetchWeatherAndUpdateUI() {
        guard let headerView = headerView else { return }
        headerView.segControl.selectedSegmentIndex == 0 ? fetchUltraShortTermWeatherAndUpdateUI() : fetchShortTermForecastAndUpdateUI()
    }
    
    private func fetchUltraShortTermWeatherAndUpdateUI() {
        guard let pm = self.placemark else { return }
        
        updateBookmarkButtonState()
        self.navigationItem.title = pm.address
 
        let nowcast_base = weatherManager.calculateBaseDateTime(for: .ultraSrtNcst)
        let nowcast_parameters = RequestParameters(basedate: nowcast_base.baseDate, basetime: nowcast_base.baseTime, nx: pm.nx, ny: pm.ny)
        
        weatherManager.fetchUltraShortTermNowcast(parameters: nowcast_parameters) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let value):
                DispatchQueue.main.async {
                    guard let headerView = self.headerView else { return }

                    headerView.tempLabel.text = "\(value.temp ?? "--")°"
                    headerView.feelsLikeLabel.text = "체감 \(value.feelsLike)°"
                    headerView.humLabel.text = "\(value.hum ?? "--")%"
                    headerView.rainLabel.text = "\(value.rain ?? "--")mm"
                    headerView.vectorLabel.text = "\(value.vecString)풍"
                    headerView.windLabel.text = "\(value.wind ?? "--")m/s"
                    headerView.basetimeLabel.text = "발표 시각: \(nowcast_base.updatedBase)"
                    headerView.updatetimeLabel.text = "최근 업데이트: \(nowcast_base.lastUpdated)"
                }
                
            case .failure(let error):
                print("초단기실황 가져오기 실패:", error)
            }
        }
        
        let forecast_base = weatherManager.calculateBaseDateTime(for: .ultraSrtFcst)
        guard let headerView = self.headerView else { return }
        
        headerView.fcstBasetimeLabel.text = "\(forecast_base.updatedBase) 발표"
        let forecast_parameters = RequestParameters(basedate: forecast_base.baseDate, basetime: forecast_base.baseTime, nx: pm.nx, ny: pm.ny)
        weatherManager.fetchUltraShortTermFcst(parameters: forecast_parameters) { [weak self] results in
            guard let self = self else { return }
            
            switch results {
            case .success(let values):
                DispatchQueue.main.async {
                    self.ultraShortTermForcasts = values
                    UIView.performWithoutAnimation {
                        self.tableView.reloadData()
                    }
                }
            case .failure(let error):
                print("초단기예보 가져오기 실패:", error)
            }
        }
        
        print(#function)
    }
    
    private func fetchShortTermForecastAndUpdateUI() {
        guard let pm = placemark else { return }
        
        let base = weatherManager.calculateBaseDateTime(for: .srtFcst)
        let parameters = RequestParameters(basedate: base.baseDate, basetime: base.baseTime, nx: pm.nx, ny: pm.ny)
        
        weatherManager.fetchShortTermFcst(parameters: parameters) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let values):
                DispatchQueue.main.async {
                    guard let headerView = self.headerView else { return }
                    
                    headerView.basetimeLabel2.text = "발표 시각: \(base.updatedBase)"
                    headerView.updatetimeLabel2.text = "최근 업데이트: \(base.lastUpdated)"
                    
                    self.shortTermForcasts = values
                    UIView.performWithoutAnimation {
                        self.tableView.reloadData()
                    }
                }
            case .failure(let error):
                print("단기예보 가져오기 실패:", error)
            }
        }
        print(#function)
    }
    
    @IBAction func bookmarkButtonTapped(_ sender: UIBarButtonItem) {
        guard placemark != nil else { return }
        
        placemark!.isBookmark.toggle()
        placemarkManager.toggleBookmark(placemark!)
        
        updateBookmarkButtonState()
    }
    
    func updateBookmarkButtonState() {
        bookmarkButton.image = placemark!.isBookmark ? UIImage(systemName: "star.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal) : UIImage(systemName: "star")?.withTintColor(.black, renderingMode: .alwaysOriginal)
    }
    
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Segue.mainToSearchIdentifier, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.mainToSearchIdentifier {
            let searchVC = segue.destination as! SearchViewController
            searchVC.bookmarkButtonPressed = { [weak self] pm in
                if pm.address == self?.placemark?.address {
                    self?.placemark?.isBookmark = pm.isBookmark
                    self?.updateBookmarkButtonState()
                }
            }
            searchVC.tableViewSelected = { [weak self] pm in
                self?.placemark = pm
                self?.fetchUltraShortTermWeatherAndUpdateUI()
                self?.placemarkManager.addRecent(pm)
            }
        }
    }
    
    @objc func currentLocationButtonTapped() {
        loadCurrentLocationWeather()
    }
    @objc func segControlChanged() {
        guard let headerView = headerView else { return }
        let showOnlySegment = (headerView.segControl.selectedSegmentIndex == 1)
        
        headerView.stackView2.arrangedSubviews.forEach {
            $0.isHidden = !showOnlySegment
        }
        
        headerView.stackView.arrangedSubviews.forEach {
            $0.isHidden = showOnlySegment
        }
        headerView.headerLabel.isHidden = showOnlySegment
        headerView.fcstBasetimeLabel.isHidden = showOnlySegment
        headerView.line.isHidden = showOnlySegment
        
        UIView.performWithoutAnimation {
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()

            let targetSize = CGSize(
            width: tableView.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
            )
            let fitting = headerView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
            )
            var frame = headerView.frame
            frame.size.height = fitting.height
            headerView.frame = frame
            tableView.tableHeaderView = headerView
        }
        
        ultraShortTermForcasts = []
        shortTermForcasts = []
        tableView.reloadData()
        
        fetchWeatherAndUpdateUI()
    }
    
    @objc func refreshButtonTapped() {
        fetchWeatherAndUpdateUI()
    }
    
}

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let headerView = headerView else { return 1 }
        return headerView.segControl.selectedSegmentIndex == 0 ? 1 : shortTermForcasts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let headerView = headerView else { return 0 }
        
        if headerView.segControl.selectedSegmentIndex == 0 {
            return ultraShortTermForcasts.count
        }
        
        let count = shortTermForcasts[section].1.count
        if count < 5 || expandedSection.contains(section) {
            return count
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let headerView = headerView else { return nil }
        
        if headerView.segControl.selectedSegmentIndex == 0 {
            return nil
        }
        
        for st in (0..<shortTermForcasts.count) {
            if section == st {
                return shortTermForcasts[st].1[0].dateString
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // 1) 세그먼트가 0이면 footer 자체가 없음
        guard let header = headerView,
              header.segControl.selectedSegmentIndex != 0 else {
            return nil
        }

        // 2) 해당 섹션 데이터 개수가 기준 초과인지
        let count = shortTermForcasts[section].1.count
        guard count > 5 else {
            return nil
        }

        // 3) 버튼 생성 (접기/더보기 토글 하나의 메서드로 통일)
        let btn = UIButton(type: .system)
        btn.tag = section
        btn.setTitle(
          expandedSection.contains(section) ? "닫기" : "더보기",
          for: .normal
        )
        btn.addTarget(self, action: #selector(toggleSection(_:)), for: .touchUpInside)
        return btn
    }
    
    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        guard let header = headerView,
              header.segControl.selectedSegmentIndex != 0 else {
            return 0
        }
        let count = shortTermForcasts[section].1.count
        return count > 5 ? 44 : 0  // 버튼 높이에 맞춰서
    }
    
    @objc func toggleSection(_ sender: UIButton) {
        let section = sender.tag
        
        if expandedSection.contains(section) {
            expandedSection.remove(sender.tag)
        } else {
            expandedSection.insert(section)
        }
        
        UIView.performWithoutAnimation {
            tableView.reloadSections(
                IndexSet(integer: section),
                with: .none
            )
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let headerView = headerView else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.forecastCell, for: indexPath) as! ForecastCell
        
        if headerView.segControl.selectedSegmentIndex == 0 {
            cell.forecast = ultraShortTermForcasts[indexPath.row]
        } else {
            let total = shortTermForcasts.count
            (0..<total).forEach {
                if indexPath.section == $0 {
                    cell.forecast = shortTermForcasts[$0].1[indexPath.row]
                }
            }
        }
        
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
