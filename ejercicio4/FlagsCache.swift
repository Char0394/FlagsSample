//
//  FlagsCache.swift
//  ejercicio4
//
//  Created by Marro Gros Gabriel on 30/11/2017.
//  Copyright © 2017 Universidad San Jorge. All rights reserved.
//

import Foundation
import UIKit

class FlagsCache {
    
    // Create a singleton. Note: static vars are lazily initialized
    static let shared = FlagsCache()
    
    // Use of cache in memory using NSCache
    lazy var cache = NSCache<NSString,UIImage>()
    
    // A class always need a constructor if doesn't inherit from a superclass
    init() {
    }
    
    // find.- Simple function that returns the image stored in memory cache. If
    //        it is not available then fetch the image from persistence (file system)
    func find(_ name:String, completion:@escaping (UIImage?)->Void) -> UIImage? {
        if let image = cache.object(forKey: name as NSString ) {
            return image
        }
        findPersistent(name, completion: completion)
        return nil
    }
    
    
    // findPersistent.- Find the image in the file system, in cache folder. If not found
    //                  then download the image
    private func findPersistent(_ name:String, completion:@escaping (UIImage?)->Void ) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            let fileManager = FileManager.default
            if let cacheFolder = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
                let fileName = name.lowercased() + ".png"
                let url = cacheFolder.appendingPathComponent(fileName)
                if fileManager.fileExists(atPath: url.path ) ,
                    let data = fileManager.contents(atPath: url.path) ,
                    let image = UIImage(data: data) {
                    
                    // Image found. Call completion in main thread and store the image in memory cache
                    
                    DispatchQueue.main.async {
                        completion(image)
                    }
                    self.cache.setObject(image, forKey: name as NSString)
                    return
                }

            }
            
            // If not found in persistence, then download the image
            self.download(name, completion:completion)
        }
    }
    
    private func download(_ name:String, completion:@escaping (UIImage?)->Void) {
        
        let urlString = baseURL + "/" + name.lowercased() + ".png"
        let url = URL(string:urlString)!
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            var image : UIImage? = nil
            if error == nil , (response as! HTTPURLResponse).statusCode == 200, data?.count ?? 0 > 0  {
                image = UIImage(data:data!)
            }
            
            // image downloaded. call completion and store the image in memory cache.
            
            DispatchQueue.main.async {
                completion(image)
            }
            if image != nil {
                self.cache.setObject(image!, forKey: name as NSString)
            }
        }
        task.resume()
    }
    
}
