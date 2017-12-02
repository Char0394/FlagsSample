//
//  CountryFlagsTableViewController.swift
//  ejercicio4
//
//  Created by Charlin Agramonte on 11/18/17.
//  Copyright © 2017 Universidad San Jorge. All rights reserved.
//

import UIKit

class CountryFlagsTableViewController: UITableViewController {
    
    lazy var filteredCountries: [[String:Any]]? = {
        return [[String:Any]]()
    }()
    
    var countries : [[String:Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        navigationItem.searchController = searchController
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Candies"
        definesPresentationContext = true
        
        weak var weakSelf = self
        
        readCountries{
            self.downloadCountryList(nil)
        }
        
        NotificationCenter.default.addObserver(forName:  Notification.Name.UIApplicationDidBecomeActive,
                                               object: nil,
                                               queue: .main) { (notification) in
                                                weakSelf?.downloadCountryList(nil)
        }
        
       
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillTerminate, object: nil,
                                               queue: .main) { (notification) in
                                                
             weakSelf?.saveCountries()
        }
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.addTarget(self,
                                            action: #selector(refreshControlAction(_:)),
                                            for: .valueChanged)
    }
    
    func readCountries(_ completion:@escaping ()->Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            let fm = FileManager.default
            if let cache = fm.urls(for: .cachesDirectory, in: .userDomainMask).first {
                let url = cache.appendingPathComponent("countries.plist")
                if fm.fileExists(atPath: url.path) {
                    if let data = fm.contents(atPath: url.path) {
                        let obj = try? PropertyListSerialization.propertyList(from: data,
                                                                              options: .mutableContainers,
                                                                              format: nil) as! [[String:Any]]
                        DispatchQueue.main.async {
                            self.countries = obj
                            self.tableView.reloadData()
                            
                            completion()
                        }
                        return
                    }
                }
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func saveCountries() {
        
        guard self.countries != nil else {
            return
        }
        
        let backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        DispatchQueue.global(qos: .background).async {
            let plist = try? PropertyListSerialization.data(fromPropertyList: self.countries!,
                                                            format: PropertyListSerialization.PropertyListFormat.xml,
                                                            options: 0)
            let fm = FileManager.default
            if let cache = fm.urls(for: .cachesDirectory, in: .userDomainMask).first {
                let url = cache.appendingPathComponent("countries.plist")
                
                var isDir : ObjCBool = false
                
                if fm.fileExists(atPath: url.path, isDirectory: &isDir) {
                    try? fm.removeItem(at: url)
                }
                
                fm.createFile(atPath: url.path, contents: plist, attributes: nil)
                
                UIApplication.shared.endBackgroundTask(backgroundTask)
            }
        }
    }
    
    @objc func refreshControlAction(_ sender: UIRefreshControl) {
        downloadCountryList(sender)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if navigationItem.searchController!.isActive , !textIsEmpty(navigationItem.searchController?.searchBar.text) {
            return filteredCountries!.count
        } else {
            return countries?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var content : [[String:Any]]
        if navigationItem.searchController!.isActive , !textIsEmpty(navigationItem.searchController?.searchBar.text) {
            content = filteredCountries!
        } else {
            content = countries!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) as! CountryCell
        
        let country = content[indexPath.row]
        cell.countryName.text = country["fullname"] as? String
        
        let countryCode = country["ianacode"] as? String
        
        cell.flag.image = nil
        
        if let imageName = countryCode?.lowercased() {
            let urlStr = baseURL + "/" + imageName + ".png"
            let url = URL(string:urlStr)!
            
            cell.fillFlag(url)
        }
        
        NSLog("Terminada la celda %@", cell.countryName.text ?? "--nulo--")
        
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            tableView.beginUpdates()
            countries!.remove(at: indexPath.row)
            tableView.deleteRows(at: [ indexPath ], with: .fade)
            tableView.endUpdates()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "detail",
            let _ = tableView.indexPathForSelectedRow?.row {
            return true
        } else {
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            var content : [[String:Any]]?
            
            if navigationItem.searchController!.isActive, navigationItem.searchController!.searchBar.text?.count ?? 0 > 0 {
                content = filteredCountries
            } else {
                content = countries
            }
            
            if let row = tableView.indexPathForSelectedRow?.row {
                let country = content![row]
                let nextVC = segue.destination as! CountryController
                
                nextVC.country = country
            }
        }
    }
    
    @IBAction func backToFlags(_ segue:UIStoryboardSegue) {
        
    }
}

extension CountryFlagsTableViewController {
    
    func downloadCountryList(_ control: UIRefreshControl?) {
        let session = URLSession.shared
        
        var url = URL(string:baseURL)!
        
        url.appendPathComponent("countryPhonePrefixCodes.plist")
        
        let request = URLRequest(url: url)
        
        weak var weakSelf = self
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil || data?.count ?? 0 > 0 else {
                DispatchQueue.main.async {
                    control?.endRefreshing()
                }
                return
            }
            
            DispatchQueue.main.async {
                weakSelf?.countries = try? PropertyListSerialization.propertyList(from: data!,
                                                                                  options: .mutableContainers,
                                                                                  format: nil) as! [[String:Any]]
                
                weakSelf?.tableView.reloadData()
                control?.endRefreshing()
                
            }
        }
        task.resume()
    }
}

