//
//  SiteTableViewController.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2018-10-18.
//  Copyright © 2018 FoxNet. All rights reserved.
//

import UIKit

class SiteTableViewController: ThemedTableViewController, UISearchResultsUpdating {
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
    
    var searchResults =  [ObservingSite]()
    
    enum Mode {
        case Countries
        case Regions
        case Search
    }
    
    let csw = ClearSkyWatcher.instance
    
    var currentMode: Mode = .Countries {
        didSet {
            switch currentMode {
            case .Countries:
                self.title = "Countries"
            case .Regions, .Search:
                self.title =  "Observing Sites"
            }
            tableView.reloadData()
        }
    }
    
    var beforeSearchMode: Mode?
    
    lazy var countries = {
        csw.getCountries()
    }()
    
    var currentCountry: String = ""
    
    var currentRegions: [Region] {
        switch currentMode {
        case .Countries, .Search:
            return [Region]()
        case .Regions:
            return csw.getRegions(inCountry: currentCountry)
        }
    }
    
    var regionIndeces: [String] {
        var indeces = Set<String>()
        currentRegions.forEach{indeces.insert(String($0.name.first!))}
        return indeces.sorted()
    }
    
    var searchController: UISearchController?
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "Countries"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
            
        })()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        switch (currentMode) {
        case .Countries, .Search:
            return 1
        case .Regions:
            return currentRegions.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        switch currentMode {
        case .Countries:
            return countries.count
        case .Regions:
            return currentRegions[section].observingSites.count
        case .Search:
            return searchResults.count
        }
        

    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentMode {
        case .Countries:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegionCell", for: indexPath)
            cell.textLabel?.text = countries[indexPath.row]
            return cell
        case .Regions:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SiteCell", for: indexPath)
            let observingSite = (currentRegions[indexPath.section].observingSites.allObjects as! [ObservingSite]).sorted(by: {$0.name < $1.name})[indexPath.row]
            cell.textLabel?.text = observingSite.name
            return cell
        case .Search:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SiteCell", for: indexPath)
            let observingSite = searchResults[indexPath.row]
            cell.textLabel?.text = observingSite.name
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch currentMode {
        case .Countries, .Search:
            return nil
        default:
            return currentRegions[section].name
        }
        
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        switch currentMode {
        case .Countries, .Search:
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
        case .Countries, .Search:
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
        case .Regions:
            if let destinationController = segue.destination as? ObservingSiteViewController {
                let cell = sender as! UITableViewCell
                let indexPath = tableView.indexPath(for: cell)!
                destinationController.observingSite = (currentRegions[indexPath.section].observingSites.allObjects as! [ObservingSite]).sorted(by: {$0.name < $1.name})[indexPath.row]
            }
        case .Search:
            if let destinationController = segue.destination as? ObservingSiteViewController {
                let cell = sender as! UITableViewCell
                let indexPath = tableView.indexPath(for: cell)!
                destinationController.observingSite = searchResults[indexPath.row]
                searchController?.isActive = false
            }
        }
        
        
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
