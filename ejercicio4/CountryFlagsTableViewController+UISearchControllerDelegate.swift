//
//  CountryFlagsTableViewController+UISearchControllerDelegate.swift
//  ejercicio4
//
//  Created by Charlin Agramonte on 11/24/17.
//  Copyright © 2017 Universidad San Jorge. All rights reserved.
//
import UIKit;

import Foundation

extension CountryFlagsTableViewController : UISearchControllerDelegate,UISearchResultsUpdating{
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredCountries = countries!.filter({( country : [String:Any]) -> Bool in
            let name = country["fullname"] as! String
            return name.lowercased().contains(searchText.lowercased())
        })
        
    }
    
    func textIsEmpty( _ text : String?) -> Bool {
        return (text?.count ?? 0 == 0)
    }
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        
        if textIsEmpty(searchText){
            filteredCountries = [[String:Any]]()
        }else{
            filterContentForSearchText(searchText!)
        }
        
        
        tableView.reloadData()
        
    }
}
