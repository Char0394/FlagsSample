//
//  CountryController.swift
//  ejercicio4
//
//  Created by Charlin Agramonte on 11/18/17.
//  Copyright © 2017 Universidad San Jorge. All rights reserved.
//

import UIKit

class CountryController: UIViewController {

    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var prefix: UILabel!
    
    @IBOutlet weak var labelTopCons: NSLayoutConstraint!
    
    var country : [String: Any]!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard country != nil else{
            return
        }
        
        name.text = country["fullname"] as? String
        flag.image = nil
        
        title = "Detail"
        prefix.text = country["itucode"] as? String
        
        flag.alpha = 0.0;
        flag.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        labelTopCons.constant = 100.0
    
    }
    
    
   
    func fillFlag( _ image: UIImage){
        flag.image = image
        weak var weakFlag = flag
        
        UIView.animate(withDuration: 0.5, animations: {
            weakFlag?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            weakFlag?.alpha = 1.0
        }) { (done:Bool) in
            UIView.animate(withDuration: 0.3, animations: {
                weakFlag?.transform = .identity
            })
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard country != nil else{
            return
        }
        if let code = country["ianacode"] as? String {
            let image = FlagsCache.shared.find(code, completion: { (image) in
                if image != nil {
                    self.fillFlag(image!)
                }
                
            })
            self.fillFlag(image!)
        }
        
        weak var weakSelf = self
        
        labelTopCons.constant = 30.0
        UIView.animate(withDuration: 0.5,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
            weakSelf?.view.layoutSubviews()
            }, completion: nil)
        
    }
    @IBAction func commentAction(_ sender: Any) {
        
    }
    
    

}
