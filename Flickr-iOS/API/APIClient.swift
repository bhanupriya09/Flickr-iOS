//
//  APIClient.swift
//  flickr
//
//  Created by Bhanupriya Swami on 11/09/18.
//  Copyright © 2018 Bhanupriya Swami. All rights reserved.
//

import UIKit

class APIClient: NSObject {
    
    var photoArray = [PhotoModel]()
    
    func getPhotos(urlString: String, completion: @escaping (([PhotoModel]?) -> Void)){
        
        let urlStr = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlStr!)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            guard let unwrappedData = data else {
                print("error getting data");
                return
            }
            
            do {
                if let responseJSON = try JSONSerialization.jsonObject(with: unwrappedData, options: .allowFragments) as? NSDictionary {
                    self.photoArray = [PhotoModel]()
                    if let photos = responseJSON["photos"] as? [String: Any] {
                        if let arr = photos["photo"] as? [[String: Any]] {
                            for result in arr{
                                if let photo = PhotoModel(json: result) {
                                    self.photoArray.append(photo)
                                }
                            }
                            completion(self.photoArray)
                        }
                    }
                }
            } catch {
                completion(nil)
                print("Error getting data from API:", error.localizedDescription)
            }
        }).resume()
        
    }
    
}
