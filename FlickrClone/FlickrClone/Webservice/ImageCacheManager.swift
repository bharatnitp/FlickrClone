
//
//  ImageCacheManager.swift
//  FlickrClone
//
//  Created by Bharat Bhushan on 07/07/18.
//  Copyright © 2018 Bharat Bhushan. All rights reserved.
//



import UIKit

class ImageCacheManager: APIRequest, WebServiceManager {

    
    /// APIRequest protocol variables
    
    var requestBody: Data?
    var headers: [String : String]?
    var url: URL?
    var httpMethod: HTTPMethod {
        return HTTPMethod.get
    }
    
    private let fileManager = FileManager.default
    
    
    /// Fetch image either from cache or from server
    ///
    /// - Parameters:
    ///   - imageId: Unique key to identify an image
    ///   - url: HTTP URL
    ///   - completion: API response, data or error
    
    func loadImage(imageId: String, url: URL, completion: @escaping (Response<Data?, APIError>) -> Void) {
        if imageExistsInCache(imageId: imageId) {
            let image = fetchImagefromCache(imageId: imageId)
            completion(.success(image))
            return
        } else {
            self.url = url
            fetchImage(with: request) { (response) in
                completion(response)
            }
        }
    }
    
    
    /// Get the path of document directory
    ///
    /// - Parameter
    /// - imageId: Unique key to identify an image
    /// - Returns: path where image is stored
    
    private func imagePath(_ imageId: String) -> URL? {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = documentDirectory?.appendingPathComponent("\(imageId)").appendingPathExtension("jpg")
        return filePath
    }
    
    
    /// Check whether image is present in Cache or not
    ///
    /// - Parameter
    /// - imageId: Unique key to identify an image
    /// - Returns: Boolean type (true or false)
    
    private func imageExistsInCache(imageId: String) -> Bool {
        guard let imagePath = imagePath(imageId)  else { return false }
        let filePath = String(describing: imagePath).replacingOccurrences(of: "file:///", with: "")
        if fileManager.fileExists(atPath: filePath) {
            return true
        }
        return false
    }
    
    
    /// Store imahe in cache
    ///
    /// - Parameters:
    ///   - imageId: Unique key to identify an image
    ///   - imageData: image data
    
    func cacheImage(imageId: String, imageData: Data) {
        if imageExistsInCache(imageId: imageId) {
            return
        }
        guard let path = imagePath(imageId) else { return }
        do {
            if let image = UIImage(data: imageData), let compressedImage = UIImageJPEGRepresentation(image, 0.5) {
                try compressedImage.write(to: path)
            }
        } catch {
            print(error)
        }
    }
    
    /// Fetch image from cache
    ///
    /// - Parameters
    /// - imageId: Unique key to identify an image
    /// - Returns:  image data if present in cache
    
    private func fetchImagefromCache(imageId: String) -> Data? {
        guard let path = imagePath(imageId) else { return nil }
        let filePath = String(describing: path).replacingOccurrences(of: "file:///", with: "")
        if let data = fileManager.contents(atPath: filePath) {
            return data
        }
        return nil
    }
}
