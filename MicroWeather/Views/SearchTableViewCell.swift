//
//  SearchTableViewCell.swift
//  MicroWeather
//
//  Created by 김정원 on 5/12/25.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    private let placemarkManager = PlacemarkManager.shared
    
    var bookmarkButtonPressed: (SearchTableViewCell) -> Void = { (sender) in }

    var placemark: Placemark?
    
    func configureUIwithData() {
        guard let pm = placemark else { return }
        
        addressLabel.text = pm.address
        bookmarkButton.setImage(pm.isBookmark ? UIImage(systemName: "star.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal) : UIImage(systemName: "star")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
    }

    @IBAction func bookmarkButtonTapped(_ sender: UIButton) {
        guard placemark != nil else { return }
        
        placemark!.isBookmark.toggle()
        placemarkManager.toggleBookmark(placemark!)
        
        bookmarkButtonPressed(self)
    }
    
}
