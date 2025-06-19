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
    
    @IBOutlet weak var loadCurrentLocationButton: UIButton!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    private lazy var firstVC: Main1ViewController = {
        let vc = storyboard!.instantiateViewController(identifier: "Main1VC") as! Main1ViewController
        addChild(vc); vc.didMove(toParent: self)
        view.addSubview(vc.view)
        setupConstraints(for: vc.view)
        return vc
    }()
    private lazy var secondVC: Main2ViewController = {
        let vc = storyboard!.instantiateViewController(identifier: "Main2VC") as! Main2ViewController
        addChild(vc); vc.didMove(toParent: self)
        view.addSubview(vc.view)
        setupConstraints(for: vc.view)
        return vc
    }()
    
    private let weatherManager = WeatherManager.shared
    private let placemarkManager = PlacemarkManager.shared
    
    var placemark: Placemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupObserver()
        loadCurrentLocationWeather()
    }
    
    private func setupUI() {
        
        segControlChanged(segControl)
    }
    
    private func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(placemarkDidChange), name: .placemarkDidChange, object: nil)
    }
    
    @objc private func placemarkDidChange(_ notification: Notification) {
        guard let newPlacemark = notification.userInfo?["newPlacemark"] as? Placemark, placemark != newPlacemark else {
            return
        }
        
        placemark = newPlacemark
        fetchUltraShortTermWeatherAndUpdateUI()
        fetchShortTermForecastAndUpdateUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func loadCurrentLocationWeather() {
        placemarkManager.loadPlacemarkOfCurrentLocation { [weak self] pm in
            guard let self = self else { return }
            guard let pm = pm else { return }
            DispatchQueue.main.async {
                self.placemark = pm
                self.placemarkManager.currentPlacemark = pm
                self.fetchUltraShortTermWeatherAndUpdateUI()
                self.fetchShortTermForecastAndUpdateUI()
            }
            self.placemarkManager.addRecent(pm)
        }
    }
    
    private func fetchUltraShortTermWeatherAndUpdateUI() {
        guard let pm = placemark else {
            self.firstVC.nowcast = nil
            return
        }
        
        updateBookmarkButtonState()
        self.navigationItem.title = pm.address
 
        let nowcast_base = weatherManager.calculateBaseDateTime(for: .ultraSrtNcst)
        let nowcast_parameters = RequestParameters(basedate: nowcast_base.baseDate, basetime: nowcast_base.baseTime, nx: pm.nx, ny: pm.ny)
        
        weatherManager.fetchUltraShortTermNowcast(parameters: nowcast_parameters) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let value):
                DispatchQueue.main.async {
                    self.firstVC.nowcast = (value, nowcast_base.updatedBase, nowcast_base.lastUpdated)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.firstVC.nowcast = nil
                }
                print("초단기실황 가져오기 실패:", error)
            }
        }
        
        let forecast_base = weatherManager.calculateBaseDateTime(for: .ultraSrtFcst)
        let forecast_parameters = RequestParameters(basedate: forecast_base.baseDate, basetime: forecast_base.baseTime, nx: pm.nx, ny: pm.ny)
        weatherManager.fetchUltraShortTermFcst(parameters: forecast_parameters) { [weak self] results in
            guard let self = self else { return }
            
            switch results {
            case .success(let values):
                DispatchQueue.main.async {
                    self.firstVC.forecasts = (values, forecast_base.updatedBase)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.firstVC.forecasts = ([], "")
                }
                print("초단기예보 가져오기 실패:", error)
            }
        }
    }
    
    private func fetchShortTermForecastAndUpdateUI() {
        guard let pm = placemark else {
            self.secondVC.forecasts = ([], "", "")
            return
        }
        
        let base = weatherManager.calculateBaseDateTime(for: .srtFcst)
        let parameters = RequestParameters(basedate: base.baseDate, basetime: base.baseTime, nx: pm.nx, ny: pm.ny)
        
        weatherManager.fetchShortTermFcst(parameters: parameters) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let values):
                DispatchQueue.main.async {
                    self.secondVC.forecasts = (values, base.updatedBase, base.lastUpdated)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.secondVC.forecasts = ([], "", "")
                }
                print("단기예보 가져오기 실패:", error)
            }
        }
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
                guard let self = self else { return }
                
                self.placemark = pm
                self.fetchUltraShortTermWeatherAndUpdateUI()
                self.fetchShortTermForecastAndUpdateUI()
                
                if let pm = pm {
                    self.placemarkManager.currentPlacemark = pm
                    self.placemarkManager.addRecent(pm)
                }
            }
        }
    }
    
    @IBAction func loadCurrentLocationButtonTapped(_ sender: UIButton) {
        loadCurrentLocationWeather()
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        fetchUltraShortTermWeatherAndUpdateUI()
        fetchShortTermForecastAndUpdateUI()
    }
    
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        let idx = segControl.selectedSegmentIndex
        
        firstVC.view.isHidden = (idx != 0)
        secondVC.view.isHidden = (idx != 1)
        self.view.backgroundColor = (idx == 0) ? .systemBackground : .systemGroupedBackground
    }
    
    private func setupConstraints(for subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 원형 코너 설정
        loadCurrentLocationButton.layer.cornerRadius = loadCurrentLocationButton.bounds.width / 2

        // 그림자 경로
        let path = UIBezierPath(roundedRect: loadCurrentLocationButton.bounds,
                                cornerRadius: loadCurrentLocationButton.bounds.width / 2)
        loadCurrentLocationButton.layer.shadowPath = path.cgPath

        // 그림자 설정
        loadCurrentLocationButton.layer.shadowColor   = UIColor.black.cgColor
        loadCurrentLocationButton.layer.shadowOpacity = 0.2
        loadCurrentLocationButton.layer.shadowOffset  = CGSize(width: 0, height: 2)
        loadCurrentLocationButton.layer.shadowRadius  = 6
        
        
        updateButton.layer.cornerRadius = updateButton.bounds.width / 2

        // 그림자 경로
        let path2 = UIBezierPath(roundedRect: updateButton.bounds,
                                cornerRadius: updateButton.bounds.width / 2)
        updateButton.layer.shadowPath = path2.cgPath

        // 그림자 설정
        updateButton.layer.shadowColor   = UIColor.black.cgColor
        updateButton.layer.shadowOpacity = 0.2
        updateButton.layer.shadowOffset  = CGSize(width: 0, height: 2)
        updateButton.layer.shadowRadius  = 6
    }
}
