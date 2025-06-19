//
//  PMViewController.swift
//  MicroWeather
//
//  Created by 김정원 on 5/29/25.
//

import UIKit

class PMViewController: UIViewController {

    private let placemarkManager = PlacemarkManager.shared
    private let pmManager = PMAPIManager.shared
    
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var updatetimeLabel: UILabel!
    
    @IBOutlet weak var loadCurrentLocationButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var placemark: Placemark?
    var stationName: String?
    var nowcast: [PMValue] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlacemark()
        setupCollectionView()
    }
    
    private func setupPlacemark() {
        if let existing = placemarkManager.currentPlacemark {
            placemark = existing
            
            fetchNowcastAndUpdateUI()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(placemarkDidChange), name: .placemarkDidChange, object: nil)
    }
    
    @objc private func placemarkDidChange(_ notification: Notification) {
        guard let newPlacemark = notification.userInfo?["newPlacemark"] as? Placemark, placemark != newPlacemark else { return }
        
        placemark = newPlacemark
        fetchNowcastAndUpdateUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func loadCurrentLocationPM() {
        placemarkManager.loadPlacemarkOfCurrentLocation { [weak self] pm in
            guard let self = self else { return }
            guard let pm = pm else { return }
            DispatchQueue.main.async {
                self.placemark = pm
                self.placemarkManager.currentPlacemark = pm
                self.fetchNowcastAndUpdateUI()
            }
            self.placemarkManager.addRecent(pm)
        }
    }
    
    private func fetchNowcastAndUpdateUI() {
        guard let pm = placemark else { return }
        let now = getCurrentTime()
        
        updateBookmarkButtonState()
        self.navigationItem.title = pm.address
        
        pmManager.fetchStationName(location: (lon: pm.lon, lat: pm.lat)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let name):
                self.stationName = name
                self.pmManager.fetchMeasurement(stationName: name) { result in
                    switch result {
                    case .success(let item):
                        DispatchQueue.main.async {
                            self.timeLabel.text = item.dataTime
                            self.updatetimeLabel.text = now
                            
                            self.nowcast.append(PMValue(type: .pm10, state: item.pm10Flag, value: item.pm10Value))
                            self.nowcast.append(PMValue(type: .pm25, state: item.pm25Flag, value: item.pm25Value))
                            self.nowcast.append(PMValue(type: .so2, state: item.so2Flag, value: item.so2Value))
                            self.nowcast.append(PMValue(type: .co, state: item.coFlag, value: item.coValue))
                            self.nowcast.append(PMValue(type: .o3, state: item.o3Flag, value: item.o3Value))
                            self.nowcast.append(PMValue(type: .no2, state: item.no2Flag, value: item.no2Value))
                            self.collectionView.reloadData()
                        }
                    case .failure(let error):
                        print("미세먼지 측정정보 가져오기 실패:", error.description)
                    }
                }
            case .failure(let error):
                self.stationName = nil
                print("미세먼지 측정소 가져오기 실패:", error.description)
            }
        }

    }
    
    private func getCurrentTime(_ now: Date = Date()) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return dateFormatter.string(from: now)
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
        performSegue(withIdentifier: Segue.pmToSearchIdentifier, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.pmToSearchIdentifier {
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
                self.fetchNowcastAndUpdateUI()
                
                if let pm = pm {
                    self.placemarkManager.currentPlacemark = pm 
                    self.placemarkManager.addRecent(pm)
                }
            }
        }
    }
    
    @IBAction func loadCurrentLocationButtonTapped(_ sender: UIButton) {
        loadCurrentLocationPM()
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        fetchNowcastAndUpdateUI()
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

extension PMViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nowcast.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == nowcast.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.pmFooterCell, for: indexPath) as! PMFooterCollectionViewCell
            
            cell.stationName = self.stationName
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.pmCell, for: indexPath) as! PMCollectionViewCell
            
            cell.data = nowcast[indexPath.row]
            
            return cell
        }
    }
    
    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if indexPath.row == nowcast.count {
            let width = collectionView.frame.width
            let size = CGSize(width: width, height: width*0.4)
            return size
        } else {
            let width = collectionView.frame.width / 2
            let size = CGSize(width: width, height: width)
            return size
        }
    }
}
