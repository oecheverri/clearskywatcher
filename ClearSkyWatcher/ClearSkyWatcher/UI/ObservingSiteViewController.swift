//
//  ObservingSiteViewController.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-16.
//  Copyright © 2019 FoxNet. All rights reserved.
//

import UIKit
import MapKit

class ObservingSiteViewController: ThemedViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var bortleLabel: UILabel!
    
    var forecasts = [String : [Forecast]]()
    var daysOfWeekUsed = [String]()
    
    var observingSite: ObservingSite? {
        didSet {
            self.title = observingSite?.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bortleLabel.isHidden = true
        collectionView.register(UINib(nibName: "ForecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ForecastCell")
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(observingSite!.latitude), longitude: CLLocationDegrees(observingSite!.longitude))
        annotation.title = self.title
        map.addAnnotation(annotation)
        map.showAnnotations([annotation], animated: true)
        map.isHidden = false
        
        ClearSkyWatcher.instance.requestForecast(forSite: observingSite!, callbackOn: onForecastsRetrieved)
    }
    
    
    func onForecastsRetrieved(forecasts: [Forecast]) {
        
        activityIndicator.stopAnimating()
        bortleLabel.text = "Bortle: \(observingSite!.bortleScale)"
        bortleLabel.isHidden = false
        for forecast in forecasts {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(secondsFromGMT: Int(60 * 60 * observingSite!.utcOffset))!
            let dateName = calendar.weekdaySymbols[calendar.component(.weekday, from: forecast.date!)]
            self.forecasts[dateName, default: []].append(forecast)
            if !daysOfWeekUsed.contains(dateName) {
                daysOfWeekUsed.append(dateName)
            }
            
            
        }
        collectionView.isHidden = false
        let flow = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        flow.headerReferenceSize = CGSize(width: 25, height: collectionView.frame.height)
        collectionView.reloadData()

    }
}

extension ObservingSiteViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecasts[daysOfWeekUsed[section]]!.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return daysOfWeekUsed.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeaderCollectionViewCell
        
        cell.dayName = daysOfWeekUsed[indexPath.section]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCell", for: indexPath) as! ForecastCollectionViewCell
        
        cell.setForecast(forecast: forecasts[daysOfWeekUsed[indexPath.section]]![indexPath.row], utcOffset: observingSite!.utcOffset)
        return cell
    }
}

extension ObservingSiteViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 50, height: collectionView.frame.height);
    }
}
