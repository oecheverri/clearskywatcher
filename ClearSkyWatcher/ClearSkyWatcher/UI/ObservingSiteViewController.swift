//
//  ObservingSiteViewController.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-11.
//  Copyright © 2019 FoxNet. All rights reserved.
//

import UIKit

class ObservingSiteViewController: ThemedViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    var observingSite: ObservingSite?
    
    var forecasts: [Forecast]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = observingSite?.name
        
        forecasts = (observingSite?.forecasts?.allObjects as! [Forecast]).sorted(by: {$0.date.isLessThan(other: $1.date)})
        
        for forecast in forecasts! {
            print(forecast)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NSDate {
    func isLessThan(other: NSDate) -> Bool {
        return self.timeIntervalSince1970 < other.timeIntervalSince1970
    }
}
