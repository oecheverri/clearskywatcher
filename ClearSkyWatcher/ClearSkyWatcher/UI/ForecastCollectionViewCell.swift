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
            let hour = calendar.component(.hour, from: forecast!.date!)
            let hourLabel: String
            
            if hour == 0 {
                hourLabel = "12AM"
            } else if hour < 12 {
                hourLabel = "\(hour)AM"
            } else if hour == 12 {
                hourLabel = "\(hour)PM"
            } else {
                hourLabel = "\(hour-12)PM"
            }
            
            timeLabel.text = hourLabel
            setGlyphPosition(of: moon, altitude: forecast!.lunarAltitude)
            setGlyphPosition(of: sun, altitude: forecast!.solarAltitude)
            setBackgroundGradient()
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
        let emptyPosition = (frame.height * 2 / 3) + 0.5
        return emptyPosition - (emptyPosition * CGFloat((altitude/90)))
    }
    
    func setGlyphPosition(of glyphView: UILabel, altitude: Double) {
        glyphView.isHidden = altitude < 0.0
        if altitude > 0.0 {
            let position = calculateSunOrMoonYPosition(altitude: altitude)
            glyphView.layer.position = CGPoint(x: glyphView.layer.position.x, y: position)            
        }
    }
    
    func setBackgroundGradient() {
        
        let gradLayer = CAGradientLayer()
        let gradBackgroundView: UIView = UIView(frame: frame)
        var colors: [CGColor] = []

        var locations: [NSNumber] = []
        let step = 1.0 / Double(forecast!.limitingMagnitudes.count - 1)
        var currentStepVal = 0.0

        for darkness in forecast!.limitingMagnitudes {
            colors.append(getUIColourFor(darkness: darkness).cgColor)
            locations.append(NSNumber(value: currentStepVal))
            currentStepVal+=step
        }

        gradLayer.colors = colors
        gradLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradLayer.locations = locations
        gradLayer.frame = bounds

        gradBackgroundView.layer.insertSublayer(gradLayer, at: 0)
        backgroundView = gradBackgroundView
    }
    
    func getUIColourFor(darkness: Double) -> UIColor {        
        if darkness >= 6.0 {
            return #colorLiteral(red: 0.001716704923, green: 0, blue: 0.1980069578, alpha: 1)
        } else if darkness >= 5.8 {
            return #colorLiteral(red: 0.00535570737, green: 0.0001972872851, blue: 0.357088238, alpha: 1)
        } else if darkness >= 5.6 {
            return #colorLiteral(red: 0.01164759323, green: 0.0007643038407, blue: 0.5161701441, alpha: 1)
        } else if darkness >= 5.4 {
            return #colorLiteral(red: 0.02150147222, green: 0.0004713170347, blue: 0.6793364286, alpha: 1)
        } else if darkness >= 5.2 {
            return #colorLiteral(red: 0.034306366, green: 0.001262995414, blue: 0.838418901, alpha: 1)
        } else if darkness >= 5 {
            return #colorLiteral(red: 0.05065163225, green: 0.0005770254065, blue: 1, alpha: 1)
        } else if darkness >= 4.5 {
            return #colorLiteral(red: 0, green: 0.1980181038, blue: 1, alpha: 1)
        } else if darkness >= 4 {
            return #colorLiteral(red: 0, green: 0.3921090364, blue: 1, alpha: 1)
        } else if darkness >= 3.5 {
            return #colorLiteral(red: 0, green: 0.6990219355, blue: 0.9981588721, alpha: 1)
        } else if darkness >= 3 {
            return #colorLiteral(red: 0.00920799654, green: 0.9989237189, blue: 0.9996764064, alpha: 1)
        } else if darkness >= 2 {
            return #colorLiteral(red: 0.9980254769, green: 0.6682758927, blue: 0.076493375, alpha: 1)
        } else if darkness >= 1 {
            return #colorLiteral(red: 0.9994223714, green: 0.7221731544, blue: 0.2341143489, alpha: 1)
        } else if darkness >= 0 {
            return #colorLiteral(red: 1, green: 0.7754734159, blue: 0.3821504116, alpha: 1)
        } else if darkness >= -1 {
            return #colorLiteral(red: 0.9991845489, green: 0.8364936709, blue: 0.539933145, alpha: 1)
        } else if darkness >= -2 {
            return #colorLiteral(red: 0.9989537597, green: 0.8886901736, blue: 0.694367826, alpha: 1)
        } else if darkness >= -3 {
            return #colorLiteral(red: 1, green: 0.944447279, blue: 0.8482723832, alpha: 1)
        } else {
            return #colorLiteral(red: 0.999904573, green: 1, blue: 0.9998808503, alpha: 1)
        }
    }
}
