//
//  SiteTableViewController.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2018-10-18.
//  Copyright © 2018 FoxNet. All rights reserved.
//

import UIKit

class SiteTableViewController: ThemedTableViewController, UISearchResultsUpdating {
    
    var searchResults = [ObservingSite]()
    
    var favouriteSites: [ObservingSite] {
        return csw.getFavouriteObservingSites()
    }
    
    enum Mode {
        case Countries
        case Regions
        case Search
        case Favourites
    }
    
    let csw = ClearSkyWatcher.instance
    
    var currentMode: Mode = .Countries {
        didSet {
            switch currentMode {
            case .Countries:
                self.title = NSLocalizedString("Countries", comment: "Countries")
            case .Regions, .Search:
                self.title =  NSLocalizedString("Observing Sites", comment: "Observing Sites")
            case .Favourites:
                self.title = NSLocalizedString("Favourite Sites", comment: "Favourite Sites")
            }
        }
    }
    
    var beforeSearchMode: Mode?
    
    lazy var countries = {
        csw.getCountries()
    }()
    
    var currentCountry: String = ""
    
    var currentRegions: [Region] {
        switch currentMode {
        case .Regions:
            return csw.getRegions(inCountry: currentCountry)
        default:
            return [Region]()
        }
    }
    
    var regionIndeces: [String] {
        var indeces = Set<String>()
        currentRegions.forEach{indeces.insert(String($0.name.first!))}
        return indeces.sorted()
    }
    
    var searchController: UISearchController?
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text!
        
        if !searchText.isEmpty {
            
            if currentMode != .Search {
                beforeSearchMode = currentMode
                currentMode = .Search
            }
            if beforeSearchMode == .Regions {
                searchResults = csw.getObervingSites(in: currentCountry, containing: searchText)
            } else {
                searchResults = csw.getObservingSites(containing: searchText)
            }
            tableView.reloadData()
        } else if currentMode == .Search {
            currentMode = beforeSearchMode ?? .Countries
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "Countries"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (currentMode != .Favourites) {
            searchController = ({
                
                let controller = UISearchController(searchResultsController: nil)
                controller.searchResultsUpdater = self
                controller.dimsBackgroundDuringPresentation = false
                controller.searchBar.sizeToFit()
                
                controller.searchBar.barTintColor = UIColor.black
                controller.searchBar.tintColor = UIColor.red
                controller.searchBar.backgroundColor = UIColor.black
                
                let textFieldInsideSearchBar = controller.searchBar.value(forKey: "searchField") as? UITextField
                
                textFieldInsideSearchBar!.textColor = UIColor.red
                textFieldInsideSearchBar!.tintColor = UIColor.red
                textFieldInsideSearchBar!.backgroundColor = UIColor.black
                textFieldInsideSearchBar!.keyboardAppearance = .dark
                tableView.tableHeaderView = controller.searchBar
                
                return controller
                
            })()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        switch (currentMode) {
        case .Regions:
            return currentRegions.count
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentMode {
        case .Countries:
            return countries.count
        case .Regions:
            return currentRegions[section].observingSites.count
        case .Search:
            return searchResults.count
        case .Favourites:
            return favouriteSites.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentMode {
        case .Countries:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegionCell", for: indexPath)
            cell.textLabel?.text = countries[indexPath.row]
            return cell
        case .Regions:
            // let observingSite = (currentRegions[indexPath.section].observingSites.allObjects as! [ObservingSite]).sorted(by: {$0.name < $1.name})[indexPath.row]
            let observingSite = currentRegions[indexPath.section].observingSitesSorted[indexPath.row]
            return createAndPopulateTableCell(with: observingSite, for: indexPath)
        case .Search:
            let observingSite = searchResults[indexPath.row]
            return createAndPopulateTableCell(with: observingSite, for: indexPath)
        case .Favourites:
            let observingSite = favouriteSites[indexPath.row]
            return createAndPopulateTableCell(with: observingSite, for: indexPath)
        }
        
    }
    
    func createAndPopulateTableCell(with observingSite: ObservingSite, for indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SiteCell", for: indexPath)
        cell.textLabel?.text = observingSite.name
        cell.detailTextLabel?.text = observingSite.isFavourite ? "⭐" : ""
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch currentMode {
        case .Countries, .Search, .Favourites:
            return nil
        default:
            return currentRegions[section].name
        }
        
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        switch currentMode {
        case .Countries, .Search, .Favourites:
            return 0
        case .Regions:
            for startIndex in 0..<currentRegions.count {
                if currentRegions[startIndex].name.starts(with: title) {
                    return startIndex
                }
            }
            return 0
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        switch currentMode {
        case .Countries, .Search, .Favourites:
            return nil
        case .Regions:
            return regionIndeces
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch(currentMode) {
        case .Countries:
            let destinationControler = segue.destination as! SiteTableViewController
            destinationControler.currentCountry = (sender as! UITableViewCell).textLabel!.text!
            destinationControler.currentMode = .Regions
            destinationControler.hidesBottomBarWhenPushed = true
        case .Regions:
            if let destinationController = segue.destination as? ObservingSiteViewController {
                let cell = sender as! UITableViewCell
                let indexPath = tableView.indexPath(for: cell)!
                //destinationController.observingSite = (currentRegions[indexPath.section].observingSites.allObjects as! [ObservingSite]).sorted(by: {$0.name < $1.name})[indexPath.row]
                destinationController.observingSite = currentRegions[indexPath.section].observingSitesSorted[indexPath.row]
                destinationController.hidesBottomBarWhenPushed = true
            }
        case .Search:
            if let destinationController = segue.destination as? ObservingSiteViewController {
                let cell = sender as! UITableViewCell
                let indexPath = tableView.indexPath(for: cell)!
                destinationController.observingSite = searchResults[indexPath.row]
                searchController?.isActive = false
                destinationController.hidesBottomBarWhenPushed = true
            }
        case .Favourites:
            if let destinationController = segue.destination as? ObservingSiteViewController {
                let cell = sender as! UITableViewCell
                let indexPath = tableView.indexPath(for: cell)!
                destinationController.observingSite = favouriteSites[indexPath.row]
                searchController?.isActive = false
                destinationController.hidesBottomBarWhenPushed = true
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var observingSite: ObservingSite?
        
        switch currentMode {
        case .Regions:
//            observingSite = (currentRegions[indexPath.section].observingSites.allObjects as! [ObservingSite]).sorted(by: {$0.name < $1.name})[indexPath.row]
            observingSite = currentRegions[indexPath.section].observingSitesSorted[indexPath.row]
        case .Search:
            observingSite = searchResults[indexPath.row]
        case .Favourites:
            observingSite = favouriteSites[indexPath.row]
        default:
            return UISwipeActionsConfiguration(actions: [])
        }
        
        let isFavourite = observingSite!.isFavourite
        
        let title = isFavourite ?
            NSLocalizedString("Unfavourite", comment: "Unfavourite") :
            NSLocalizedString("Favourite", comment: "Favourite")
        
        let action = UIContextualAction(style: .normal, title: title) { (action, view, completionHandler) in
            guard let observingSite = observingSite else {
                completionHandler(true)
                return
            }
            
            isFavourite ? self.csw.unfavourite(observingSite: observingSite) : self.csw.favourite(observingSite: observingSite)
            completionHandler(true)
            tableView.reloadData()
        }
        
        action.image = UIImage(named: "heart")
        action.backgroundColor = isFavourite ? .red : .green
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration

    }

}
