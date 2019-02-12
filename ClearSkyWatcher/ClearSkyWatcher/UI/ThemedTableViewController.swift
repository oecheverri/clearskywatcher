//
//  TableViewController.swift
//  ClearSkyWatcher
//
//  Created by Oscar Echeverri on 2019-02-11.
//  Copyright © 2019 FoxNet. All rights reserved.
//

import UIKit

class ThemedTableViewController: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UIColor.black
        self.tableView.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.view.backgroundColor = UIColor.black
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.textColor = UIColor.red
        cell.detailTextLabel?.textColor = UIColor.red
        cell.backgroundColor = UIColor.black
    }
}
