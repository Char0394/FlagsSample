//
//  CountryCell.swift
//  ejercicio4
//
//  Created by Charlin Agramonte on 11/18/17.
//  Copyright © 2017 Universidad San Jorge. All rights reserved.
//

import UIKit

class CountryCell: UITableViewCell {

    @IBOutlet var flag : UIImageView!
    @IBOutlet var countryName : UILabel!

    var task: URLSessionTask?
    func fillFlag(_ url : URL){
        if task != nil {
             task?.cancel()
        }
        
        let session = URLSession.shared
        
        weak var weakSelf = self
        
        task = session.dataTask(with: url){ data, response, error in
            
            weakSelf?.task = nil
            
            guard error == nil, data?.count ?? 0 > 0 else{
                return
            }
            
            if let image = UIImage(data: data!){
                DispatchQueue.main.async {
                    self.flag.image = image
                }
            }
        }
        task!.resume()
    }
}
