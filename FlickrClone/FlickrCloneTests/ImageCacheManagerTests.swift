//
//  ImageCacheManagerTests.swift
//  FlickrCloneTests
//
//  Created by Bharat Bhushan on 08/07/18.
//  Copyright © 2018 Bharat Bhushan. All rights reserved.
//
@testable import FlickrClone
import XCTest

final class ImageCacheManagerTests: XCTestCase {
    
    private var imageCacheManager: ImageCacheManager!
    
    override func setUp() {
        super.setUp()
        imageCacheManager = ImageCacheManager()
        XCTAssertNotNil(imageCacheManager)
    }
    
    override func tearDown() {
        super.tearDown()
        imageCacheManager = nil
        XCTAssertNil(imageCacheManager)
    }
    
    func test_cacheImage() {
        let image = UIImage(named: "placeholder")!
        let imageData = UIImageJPEGRepresentation(image, 0.5)!
        XCTAssertNotNil(imageCacheManager.cacheImage(imageId: "123456", imageData: imageData))
    }
    
    func test_fetchImage() {
        let reuqest = URLRequest(url: URL(string: "https://farm1.static.flickr.com/918/43275715181_43c847aa71.jpg")!)
        imageCacheManager.fetchImage(with: reuqest) { (response) in
            switch response {
            case .success(let data):
                XCTAssertNotNil(data)
            case .failure(let error):
                XCTAssertNotNil(error.localizedDescription)
            }
        }
    }
    
    func test_loadImage() {
        let url = URL(string: "https://farm1.static.flickr.com/918/43275715181_43c847aa71.jpg")!
        imageCacheManager.loadImage(imageId: "12345", url: url) { (response) in
            switch response {
            case .success(let data):
                XCTAssertNotNil(data)
            case .failure(let error):
                XCTAssertNotNil(error.localizedDescription)
            }
        }

    }
    
}
