//
//  ListingViewModelTests.swift
//  FlickrCloneTests
//
//  Created by Bharat Bhushan on 08/07/18.
//  Copyright © 2018 Bharat Bhushan. All rights reserved.
//

@testable import FlickrClone
import XCTest

final class ListingViewModelTests: XCTestCase {
    
    
    private var viewModel: ImageListingViewModel!
    
    override func setUp() {
        super.setUp()
        let viewController = ImageListingViewController()
        viewModel = ImageListingViewModel(delegate: viewController)
        
        XCTAssertNotNil(viewModel)
        XCTAssertNotNil(viewModel.delegate)
        XCTAssertNotNil(viewModel.interactor)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        viewModel = nil
        XCTAssertNil(viewModel)
    }
    
    func test_allvariables() {
        XCTAssertEqual(viewModel.numberOfColumns, 3)
        XCTAssertEqual(viewModel.minSpacingBetweenCells, 10)
        XCTAssertEqual(viewModel.numberOfColumns, 3)
        XCTAssertEqual(viewModel.cellheight, 160)
        XCTAssertNotNil(viewModel.images)
        XCTAssertTrue(viewModel.currentPageIndex > 0)
        XCTAssertEqual(viewModel.isNextPageRequestInProgress, false)
        
    }
    
    func test_NumberOfItems() {
        XCTAssertTrue(viewModel.totalNumberOfImages() == viewModel.images.count)
    }
    
    func test_searchImages() {
        XCTAssertNotNil(viewModel.searchImages(forText: "UBER"))
        XCTAssertEqual(viewModel.isNextPageRequestInProgress, false)
        XCTAssertEqual(viewModel.isNextPageRequestInProgress, viewModel.searchImagesForNextPage())
    }
}
