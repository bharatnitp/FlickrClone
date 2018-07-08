//
//  ImageListingInteractor.swift
//  FlickrClone
//
//  Created by Bharat Bhushan on 07/07/18.
//  Copyright © 2018 Bharat Bhushan. All rights reserved.
//

import UIKit

class ImageListingInteractor: APIRequest, WebServiceManager {
    
    var requestBody: Data?
    var headers: [String : String]?
    var url: URL? = URL(string: NetworkConstants.imagesMetaDataURL)
    var httpMethod: HTTPMethod {
        return HTTPMethod.get
    }
    
    
    
    /// Update the request parameters to search image based on searched text
    ///
    /// - Parameters:
    ///   - page: page number
    ///   - text: input text
    
    func updateRequestParameters(page: Int, searchText text: String) {
        if let url = request.url?.addQueryParameters(page, andSearchText: text) {
            self.url = url
        }
    }
    
    
    
    /// fetch image list from server
    ///
    /// - Parameter completion: response model
    
    func getImageList(completion: @escaping (Response<ResponseModel?, APIError>) -> Void) {
        fetch(with: request, decode: { (response) -> ResponseModel? in
            guard let model = response as? ResponseModel else { return  nil }
            return model
        }, completion: completion)
    }
}
