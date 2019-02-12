//
//  ThemeManager.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2018-05-18.
//  Copyright © 2018 FoxNet. All rights reserved.
//

import Foundation
import UIKit

struct ThemeManager {
    
    static var backgroundColor:UIColor?
    static var buttonTextColor:UIColor?
    static var buttonBackgroundColor:UIColor?
    
    static public func defaultTheme() {
        self.backgroundColor = UIColor.white
        self.buttonTextColor = UIColor.blue
        self.buttonBackgroundColor = UIColor.white
        updateDisplay()
    }
    
    
    static func darkTheme() {
        self.backgroundColor = UIColor.black
        self.buttonTextColor = UIColor.red
        self.buttonBackgroundColor = UIColor.black
        updateDisplay()
    }
    
    static public func updateDisplay() {
        
        let proxyButton = UIButton.appearance()
        proxyButton.setTitleColor(ThemeManager.buttonTextColor, for: .normal)
        proxyButton.backgroundColor = ThemeManager.buttonBackgroundColor
        
        
        let proxyView = UIView.appearance()
        proxyView.backgroundColor = ThemeManager.backgroundColor
        proxyView.tintColor = UIColor.red
        
    }
}
