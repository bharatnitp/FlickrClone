//
//  ResponseModel.swift
//  FlickrClone
//
//  Created by Bharat Bhushan on 07/07/18.
//  Copyright © 2018 Bharat Bhushan. All rights reserved.
//

import UIKit

struct ResponseModel: Decodable {
    var metadata: PhotoModel
    enum CodingKeys: String, CodingKey {
        case metadata = "photos"
    }
}

struct PhotoModel: Decodable {
    var page: Int
    var pages: Int
    var perpage: Int
    var total: String
    var imageItems: [ImageItem]
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case pages = "pages"
        case perpage = "perpage"
        case total = "total"
        case imageItems = "photo"
    }
}

struct ImageItem: Decodable {
    var id: String
    var farm: Int
    var server: String
    var secret: String
    var title: String?
    var owner: String?
    var isPublic: Int?
    var isFriend: Int?
    var isFamily: Int?
    
    func getImageUrl() -> URL? {
        let urlString = String(format: NetworkConstants.imageURLString, self.farm, self.server, self.id, self.secret)
        return URL(string: urlString)
    }
}

