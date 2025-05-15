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
    
    var address: String?
    var coordinate: (nx: String, ny: String)? {
        didSet {
            fetchUltraShortTermWeatherAndUpdateUI()
        }
    }
    
    var ultraShortTermForcasts: [ForecastValue] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableview()
        
        loadCurrentLocationWeather()
    }
    
    private func setupUI() {
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
            
            locationManager.convertLocationToAddress(location: location) { addr in
                DispatchQueue.main.async {
                    self.navigationItem.title = addr ?? "주소 정보 없음"
                }
            }
            DispatchQueue.main.async {  //didSet -> fetchUSTOAndUpdateUI() 실행 -> 뷰 변경 사항 있으므로 main에서 실행
                self.coordinate = self.locationManager.convertLocationToCoordinate(location: location)
            }
        }
    }
    
    private func fetchUltraShortTermWeatherAndUpdateUI() {
        guard let coordinate = self.coordinate else { return }
 
        let nowcast_base = weatherManager.calculateBaseDateTime(for: .ultraSrtNcst)
        let nowcast_parameters = RequestParameters(basedate: nowcast_base.baseDate, basetime: nowcast_base.baseTime, nx: coordinate.nx, ny: coordinate.ny)
        
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
        let forecast_parameters = RequestParameters(basedate: forecast_base.baseDate, basetime: forecast_base.baseTime, nx: coordinate.nx, ny: coordinate.ny)
        weatherManager.fetchUltraShortTermFcst(parameters: forecast_parameters) { [weak self] results in
            guard let self = self else { return }
            
            switch results {
            case .success(let values):
                DispatchQueue.main.async {
                    self.ultraShortTermForcasts = values
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("초단기예보 가져오기 실패:", error)
            }
        }
    }
    
    @IBAction func bookmarkButtonTapped(_ sender: UIBarButtonItem) {
    }
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Segue.mainToSearchIdentifier, sender: nil)
    }
    
    
    @objc func currentLocationButtonTapped(_ sender: UIButton) {
        self.loadCurrentLocationWeather()
    }
    @objc func segControlChanged(_ sender: UISegmentedControl) {
    }
    
    @objc func refreshButtonTapped(_ sender: UIButton) {
        fetchUltraShortTermWeatherAndUpdateUI()
    }
    
}

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ultraShortTermForcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.ultrafcstCell, for: indexPath) as! UltraShortTermForecastCell
        
        cell.forecast = ultraShortTermForcasts[indexPath.row]
            
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
