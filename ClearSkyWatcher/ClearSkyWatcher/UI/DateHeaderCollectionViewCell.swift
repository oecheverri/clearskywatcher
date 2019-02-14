//
//  DateHeaderCollectionViewCell.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-18.
//  Copyright © 2019 FoxNet. All rights reserved.
//

import UIKit

class DateHeaderCollectionViewCell: UICollectionReusableView {
    @IBOutlet weak var dateName: UILabel!
    var dayName: String = "" {
        didSet {
            var labelString = ""
            for letter in dayName {
                labelString.append(letter)
                labelString.append("\n")
            }
            dateName.text = String(labelString.dropLast())
        }
    }
}
