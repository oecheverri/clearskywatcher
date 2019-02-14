//
//  ForecastCollectionViewCell.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-16.
//  Copyright © 2019 FoxNet. All rights reserved.
//

import UIKit

@IBDesignable
class ForecastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var moon: UILabel!
    @IBOutlet weak var sun: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var ground: UIView!
    @IBOutlet weak var sky: UIView!
    
    private var utcOffset = 0.0
    private var forecast: Forecast? {
        didSet {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.init(secondsFromGMT: Int((utcOffset * 60 * 60)))!
            let hour = Double(calendar.component(.hour, from: forecast!.date!))
            timeLabel.text = String(hour)
            setGlyphPosition(glyphView: moon, altitude: forecast!.lunarAltitude)
            setGlyphPosition(glyphView: sun, altitude: forecast!.solarAltitude)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.purple
    }
    
    func setForecast(forecast: Forecast, utcOffset: Double) {
        self.utcOffset = utcOffset
        self.forecast = forecast
    }
    func calculateSunOrMoonYPosition(altitude: Double) -> CGFloat {
        let emptyPosition = (frame.height / 2) + 0.5
        return emptyPosition - (emptyPosition * CGFloat((altitude/90)))
    }
    
    func setGlyphPosition(glyphView: UILabel, altitude: Double) {
        glyphView.isHidden = altitude < 0.0
        if altitude > 0.0 {
            let position = calculateSunOrMoonYPosition(altitude: altitude)
            glyphView.layer.position = CGPoint(x: glyphView.layer.position.x, y: position)            
        }
    }

}
