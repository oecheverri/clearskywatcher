//
//  FavouritesViewController.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-06-21.
//  Copyright © 2019 FoxNet. All rights reserved.
//

import UIKit

class FavouritesViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let favouriteObservingSiteList = viewControllers[0] as! SiteTableViewController
        favouriteObservingSiteList.currentMode = .Favourites
        
    }
}
