//
//  PhotoModal.swift
//  flickr
//
//  Created by Bhanupriya Swami on 11/09/18.
//  Copyright © 2018 Bhanupriya Swami. All rights reserved.
//

import Foundation

struct PhotoModel {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
            let owner = json["owner"] as? String,
            let secret = json["secret"] as? String,
            let server = json["server"] as? String,
            let farm = json["farm"] as? Int,
            let title = json["title"] as? String,
            let ispublic = json["ispublic"] as? Int,
            let isfriend = json["isfriend"] as? Int,
            let isfamily = json["isfamily"] as? Int
            
            else{
                return nil
        }
        
        self.id = id
        self.owner = owner
        self.secret = secret
        self.server = server
        self.farm = farm
        self.title = title
        self.ispublic = ispublic
        self.isfriend = isfriend
        self.isfamily = isfamily
    }
}
