//
//  ViewController.swift
//  Flickr-iOS
//
//  Created by Bhanupriya Swami on 11/09/18.
//  Copyright © 2018 Bhanupriya. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    let fixedUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&format=json&nojsoncallback=1&safe_search=1&text="
    
    @IBOutlet var photoViewModel: PhotoViewModel!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!
    var searchTerm = ""
    var isSameSearch = false
    var isFirstResult = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initViewModel()
    }
    
    func initViewModel() {
        
        photoViewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.photoViewModel.alertMessage {
                    self?.showAlert( str: message )
                }
            }
        }
        
        photoViewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.photoViewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                }else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        
        photoViewModel.reloadCollectionViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        photoViewModel.scrollToTopClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
        
    }
    
    func showAlert(str: String) {
        let alert = UIAlertController(title: "No Internet", message: str, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController : UICollectionViewDataSource {
    
    //MARK:- Collectionview datasource
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return photoViewModel.sizeOfItem(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoViewModel.numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.imageView.image = nil;
        cell.imageView.tag = indexPath.item
        cell.tag = indexPath.row
        photoViewModel.imageTpDisplay(for: indexPath, completion: {(image) in
            DispatchQueue.main.async {
                if image != nil {
                    if cell.tag == indexPath.row {
                        cell.imageView.image = image
                    }
                }
                else{
                    cell.imageView.image = UIImage(named: "images")
                }
            }
        })
        if indexPath.row + 3 >= (photoViewModel.photosArray.count){
            photoViewModel.getData(urlString: fixedUrl + searchTerm, isSameSearch: true)
        }
        
        return cell
        
    }
    
}

extension ViewController : UISearchBarDelegate {
    
    //MARK:- search bar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if searchBar.text == "" {
            //print("blank")
        }
        else{
            searchTerm = searchBar.text!
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            photoViewModel.getData(urlString: fixedUrl + searchBar.text!, isSameSearch: false)
        }
    }
    
}

