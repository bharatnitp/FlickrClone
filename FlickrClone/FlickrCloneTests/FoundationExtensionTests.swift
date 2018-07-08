//
//  FoundationExtensionTests.swift
//  FlickrCloneTests
//
//  Created by Bharat Bhushan on 08/07/18.
//  Copyright © 2018 Bharat Bhushan. All rights reserved.
//
@testable import FlickrClone
import XCTest

final class FoundationExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    func test_addQueryParameters() {
        var url = URL(string: NetworkConstants.imagesMetaDataURL)
        url = url?.addQueryParameters(1, andSearchText: "UBER")
        XCTAssertNotNil(url)
    }
    
    func test_showAlert() {
        let viewController = UIViewController()
        XCTAssertNotNil(viewController.showAlert(withTitle: "Hello", message: "UBER"))
    }
}
