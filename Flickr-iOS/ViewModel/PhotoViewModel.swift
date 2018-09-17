//
//  PhotoViewModel.swift
//  flickr
//
//  Created by Bhanupriya Swami on 11/09/18.
//  Copyright © 2018 Bhanupriya Swami. All rights reserved.
//

import UIKit

class PhotoViewModel: NSObject {
    
    @IBOutlet weak var apiClient: APIClient!
    
    //var photoArray : [PhotoModal]?
    var page = 1
    var per_page = 100
    var isFirstResult = true
    
    var photosArray: [PhotoModel] = [PhotoModel]() {
        didSet {
            self.reloadCollectionViewClosure?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var numberOfCells: Int {
        return photosArray.count
    }
    
    var scrollToIndex : Int? {
        didSet {
            self.scrollToTopClosure?()
        }
    }
    
    var reloadCollectionViewClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    var scrollToTopClosure: (()->())?
    
    func getData(urlString: String, isSameSearch : Bool ) {
        
        if Reachability.isConnectedToNetwork(){
            if isSameSearch{
                page += 1
                per_page += 100
            }
            else{
                page = 1
                per_page = 100
            }
            let urlStr = urlString + "&page=\(self.page)" + "&per_page=\(self.per_page)"
            self.apiClient.getPhotos(urlString: urlStr){(dict) in
                DispatchQueue.main.async {
                    if isSameSearch {
                        if let arr = dict {
                            self.photosArray.append(contentsOf: arr)
                        }
                    }
                    else{
                        self.photosArray = dict!
                    }
                    
                    self.isLoading = false
                    if self.isFirstResult {
                        self.isFirstResult = false
                    }
                    else{
                        if !isSameSearch{
                            self.scrollToIndex = 0
                        }
                    }
                }
            }
        }
        else{
            DispatchQueue.main.async {
                self.isLoading = false
                self.alertMessage = "The Internet connection appears to be offline."
            }
        }
    }
    
    func sizeOfItem(for indexPath: IndexPath) -> CGSize {
        let numberOfCell: CGFloat = 3
        let cellWidth = (UIScreen.main.bounds.size.width - 20) / numberOfCell
        return CGSize(width: cellWidth, height: 80)
    }
    
    func imageTpDisplay(for indexPath: IndexPath, completion: @escaping (_ image: UIImage?) -> ()) {
        
        let model =  photosArray[indexPath.row]
        
        let imageUrl = "https://farm" + String(model.farm) + ".static.flickr.com/" + model.server +  "/" + model.id + "_" + model.secret + ".jpg"
        
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let url = URL(string: imageUrl)
        let imageName = url?.lastPathComponent
        let fileURL = documentsDirectoryURL.appendingPathComponent(imageName!)
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            let task = URLSession.shared.dataTask(with: URL(string: imageUrl)!, completionHandler: {(responseData, urlResponse, error) in
                if let dataNotNil = responseData {
                    completion(UIImage(data: dataNotNil))
                    FileManager.default.createFile(atPath: fileURL.path, contents: dataNotNil, attributes: nil)
                }
                else{
                    completion(nil)
                }
            })
            task.resume()
        } else {
            //print("file already exists")
            completion(UIImage(contentsOfFile: fileURL.path))
        }
    }
    
}
