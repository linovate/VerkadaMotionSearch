//  CustomImageView.swift
//  VerkadaMotionSearch
//  Created by lordofming on 4/4/19.
//  Copyright © 2019 lordofming. All rights reserved.

import UIKit

let imageCache = NSCache<NSString, UIImage>()

class CustomImageView: UIImageView {
    
    var imageUrlString: String?
    
    func loadImageUsingUrlString(_ urlString: String) {
        
        imageUrlString = urlString
        
        let url = URL(string: urlString)
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, respones, error) in
            
            if error != nil {
                print("Error in URLSession.shared.dataTask()")
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if data == nil{
                    print("data is nil in URLSession.shared.dataTask()")
                    return
                }
                
                let imageToCache = UIImage(data: data!)
                
                //because this is async, and it take time to download the image, after data is downloaded, use might have tried to downloaded another image during the waiting. so the "self.imageUrlString" captured in the original image download might be different from the current "urlString" formal variable.
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                }
                
                if imageToCache != nil{
                    imageCache.setObject(imageToCache!, forKey: urlString as NSString)
                }
                
            })
            
        }).resume()
    }
    
}


