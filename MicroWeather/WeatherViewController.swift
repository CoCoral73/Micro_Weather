//
//  ViewController.swift
//  MicroWeather
//
//  Created by 김정원 on 4/18/25.
//

import UIKit

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBOutlet weak var segControl: UISegmentedControl!

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var feelsLikeLable: UILabel!
    
    @IBOutlet weak var humLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var vectorLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    @IBOutlet weak var basetimeLabel: UILabel!
    @IBOutlet weak var updatetimeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    private let weatherManager = WeatherManager.shared
    
    private var location: (nx: String, ny: String) = ("55", "127")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableview()
        
        fetchUSTOAndUpdateUI()
    }
    
    private func fetchUSTOAndUpdateUI() {
        let base = calculateBaseDateTime(for: .ultraSrtNcst)
        let parameters = RequestParameters(basedate: base.baseDate, basetime: base.baseTime, nx: location.nx, ny: location.ny)
        weatherManager.fetchUltraShortTermNowcast(parameters: parameters) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        self.tempLabel.text = "\(value.temp ?? "--")°"
                        self.humLabel.text = "\(value.hum ?? "--")%"
                        self.rainLabel.text = "\(value.rain ?? "--")mm"
                        self.vectorLabel.text = "\(value.vecString)풍"
                        self.windLabel.text = "\(value.wind ?? "--")m/s"
                        self.basetimeLabel.text = "발표 시각: \(base.baseDate) \(base.baseTime)"
                        self.updatetimeLabel.text = "최근 업데이트: \(base.baseDate) \(base.baseTime)"
                    }
                    
                case .failure(let error):
                    // 에러 표시 (토스트, 얼럿 등)
                    print("날씨 가져오기 실패:", error)
                }
        }
    }

    func calculateBaseDateTime(for apiType: WeatherAPIType, now: Date = Date(), calendar: Calendar = Calendar.current) -> (baseDate: String, baseTime: String) {
        // 1) 포맷터 준비
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.dateFormat = "HHmm"
        
        // 2) basetime 후보 및 valid 계산용
        var candidateTimes: [Date] = []
        switch apiType {
        case .ultraSrtNcst:
            // 매시 :00
            var c = calendar.dateComponents([.year, .month, .day, .hour], from: now)
            c.minute = 0
            let floor = calendar.date(from: c)!
            let valid = calendar.date(byAdding: .minute, value: 10, to: floor)!
            // valid 이전이면 이전 시각, 이후면 그대로
            let baseDT = now < valid ? calendar.date(byAdding: .hour, value: -1, to: floor)! : floor
            candidateTimes = [baseDT]
            
        case .ultraSrtFcst:
            // 매시 :30
            var c = calendar.dateComponents([.year, .month, .day, .hour], from: now)
            c.minute = 30
            let floor = calendar.date(from: c)!
            let valid = calendar.date(byAdding: .minute, value: 15, to: floor)!
            let baseDT = now < valid ? calendar.date(byAdding: .hour, value: -1, to: floor)! : floor
            candidateTimes = [baseDT]
            
        case .srtFcst:
            // 기준 시각 목록
            let hours = [2,5,8,11,14,17,20,23]
            // 오늘 날짜의 각 후보 시각
            candidateTimes = hours.compactMap { h in
                var comps = calendar.dateComponents([.year, .month, .day], from: now)
                comps.hour = h; comps.minute = 0
                return calendar.date(from: comps)
            }
            // validTime = candidate + 10분
            let valids = candidateTimes.map {
                calendar.date(byAdding: .minute, value: 10, to: $0)!
            }
            // valid ≤ now 인 것 중 최신 것 선택
            let past = zip(candidateTimes, valids).filter { _, validTime in validTime <= now }
            
            if let (chosen, _) = past.max(by: { $0.0 < $1.0 }) {
                candidateTimes = [chosen]
            } else {
                // 아직 첫 타임도 유효 전 → 어제 23:00
                var yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
                var comps = calendar.dateComponents([.year, .month, .day], from: yesterday)
                comps.hour = 23; comps.minute = 0
                let dt = calendar.date(from: comps)!
                candidateTimes = [dt]
            }
        default:
            break
        }
        
        // 3) 최종 baseDateTime
        let baseDT = candidateTimes.first!
        let baseDate = dateFormatter.string(from: baseDT)
        let baseTime = timeFormatter.string(from: baseDT)
        return (baseDate, baseTime)
    }
    

    private func setupUI() {
        self.navigationItem.title = "서울시 동작구 사당4동"
        self.tabBarItem = UITabBarItem(title: "날씨", image: UIImage(systemName: "star"), selectedImage: UIImage(systemName: "star.fill"))
        
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
    
    
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
    }
    
}

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UltraSrtFcstCell", for: indexPath) as! UltraShortTermForecastCell
            
        cell.timeLabel.text = "오후 3시"
        cell.tempLabel.text = "23°"
        cell.iconView.image = UIImage(systemName: "sun.max")
            
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
        dateLabel.text = "2025-04-18 11:30 발표"
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
