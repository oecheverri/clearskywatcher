//
//  ThemedViewController.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-11.
//  Copyright © 2019 FoxNet. All rights reserved.
//

import UIKit

class ThemedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.barStyle = .black
    }

}
