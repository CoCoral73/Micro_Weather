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
    
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var refreshButton: UIButton!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    
    @IBOutlet weak var humLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var vectorLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    @IBOutlet weak var basetimeLabel: UILabel!
    @IBOutlet weak var updatetimeLabel: UILabel!
    
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
    var tableViewHeaderDateString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableview()
        
        loadCurrentLocationWeather()
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
                        self.tempLabel.text = "\(value.temp ?? "--")°"
                        self.feelsLikeLabel.text = "체감 \(value.feelsLike)°"
                        self.humLabel.text = "\(value.hum ?? "--")%"
                        self.rainLabel.text = "\(value.rain ?? "--")mm"
                        self.vectorLabel.text = "\(value.vecString)풍"
                        self.windLabel.text = "\(value.wind ?? "--")m/s"
                        self.basetimeLabel.text = "발표 시각: \(nowcast_base.updatedBase)"
                        self.updatetimeLabel.text = "최근 업데이트: \(nowcast_base.lastUpdated)"
                    }
                    
                case .failure(let error):
                    print("초단기실황 가져오기 실패:", error)
                }
        }
        
        let forecast_base = weatherManager.calculateBaseDateTime(for: .ultraSrtFcst)
        self.tableViewHeaderDateString = forecast_base.updatedBase
        let forecast_parameters = RequestParameters(basedate: forecast_base.baseDate, basetime: forecast_base.baseTime, nx: coordinate.nx, ny: coordinate.ny)
        weatherManager.fetchUltraShortTermFcst(parameters: forecast_parameters) { [weak self] results in
            guard let self = self else { return }
            
            switch results {
            case .success(let values):
                DispatchQueue.main.async {
                    self.ultraShortTermForcasts = values
                    self.tableView.tableHeaderView = self.makeTableHeader()
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("초단기예보 가져오기 실패:", error)
            }
        }
    }

    private func setupUI() {
        self.tabBarItem = UITabBarItem(title: "날씨", image: UIImage(systemName: "star"), selectedImage: UIImage(systemName: "star.fill"))
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 원형 코너 설정
        currentLocationButton.layer.cornerRadius = currentLocationButton.bounds.width / 2

        // 그림자 경로
        let path = UIBezierPath(roundedRect: currentLocationButton.bounds,
                                cornerRadius: currentLocationButton.bounds.width / 2)
        currentLocationButton.layer.shadowPath = path.cgPath

        // 그림자 설정
        currentLocationButton.layer.shadowColor   = UIColor.black.cgColor
        currentLocationButton.layer.shadowOpacity = 0.2
        currentLocationButton.layer.shadowOffset  = CGSize(width: 0, height: 2)
        currentLocationButton.layer.shadowRadius  = 6
        
        
        refreshButton.layer.cornerRadius = refreshButton.bounds.width / 2

        // 그림자 경로
        let path2 = UIBezierPath(roundedRect: refreshButton.bounds,
                                cornerRadius: refreshButton.bounds.width / 2)
        refreshButton.layer.shadowPath = path2.cgPath

        // 그림자 설정
        refreshButton.layer.shadowColor   = UIColor.black.cgColor
        refreshButton.layer.shadowOpacity = 0.2
        refreshButton.layer.shadowOffset  = CGSize(width: 0, height: 2)
        refreshButton.layer.shadowRadius  = 6
    }
    
    func setupTableview() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 50
        tableView.tableHeaderView = makeTableHeader()
        tableView.tableFooterView = makeTableFooter()
    }
    
    @IBAction func bookmarkButtonTapped(_ sender: UIBarButtonItem) {
    }
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    
    @IBAction func currentLocationButtonTapped(_ sender: UIButton) {
        self.loadCurrentLocationWeather()
    }
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        fetchUltraShortTermWeatherAndUpdateUI()
    }
    
    
}

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ultraShortTermForcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UltraSrtFcstCell", for: indexPath) as! UltraShortTermForecastCell
        
        cell.forecast = ultraShortTermForcasts[indexPath.row]
            
        return cell
    }
    
    func makeTableHeader() -> UIView {
        // 1) 전체 헤더 컨테이너
        let header = UIView()
        header.backgroundColor = .clear
        // 프레임 높이는 나중에 tableHeaderView에 적용할 때 설정해 줍니다.
        
        // 3) 왼쪽 레이블
        let titleLabel = UILabel()
        titleLabel.text = "초단기예보"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(titleLabel)
        
        // 4) 오른쪽 레이블
        let dateLabel = UILabel()
        dateLabel.text = "\(tableViewHeaderDateString) 발표"
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textAlignment = .right
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(dateLabel)
        
        // 2) 굵은 구분선
        let line = UIView()
        line.backgroundColor = .black
        line.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(line)
        
        // 5) Auto Layout 제약 걸기
        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(equalTo: header.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 22),
            
            dateLabel.bottomAnchor.constraint(equalTo: line.topAnchor, constant: -8),
            dateLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -22),
            
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
