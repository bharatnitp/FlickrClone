//
//  ModelTests.swift
//  FlickrCloneTests
//
//  Created by Bharat Bhushan on 08/07/18.
//  Copyright © 2018 Bharat Bhushan. All rights reserved.
//
@testable import FlickrClone
import XCTest

final class ModelTests: XCTestCase {
    
    private var responseModel: ResponseModel!
    
    override func setUp() {
        super.setUp()
        let imageItem = ImageItem(id: "1", farm: 1, server: "UBER",
                                  secret: "true", title: "Vehicle",
                                  owner: "self", isPublic: 0,
                                  isFriend: 0, isFamily: 1)
        XCTAssertNotNil(imageItem)
        
        let photModel = PhotoModel(page: 0, pages: 1, perpage: 100, total: "1000", imageItems: [imageItem])
        XCTAssertNotNil(photModel)
        
        responseModel = ResponseModel(metadata: photModel)
        XCTAssertNotNil(responseModel)
    }
    
    override func tearDown() {
        super.tearDown()
        responseModel = nil
        XCTAssertNil(responseModel)
    }
    
    func test_ResponseModel() {
        
    }
    
}
