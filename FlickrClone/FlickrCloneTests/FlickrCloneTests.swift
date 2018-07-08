//
//  FlickrCloneTests.swift
//  FlickrCloneTests
//
//  Created by Bharat Bhushan on 08/07/18.
//  Copyright © 2018 Bharat Bhushan. All rights reserved.
//

@testable import FlickrClone
import XCTest

final class FlickrCloneTests: XCTestCase {
    
    private var imageListingViewController: ImageListingViewController!
    private var  viewModel: ImageListingViewModel!
    private var images: [ImageItem]!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController  = storyboard.instantiateViewController(withIdentifier: "navigationViewController") as? UINavigationController
        imageListingViewController = navigationController?.viewControllers.first as? ImageListingViewController
        
        XCTAssertNotNil(imageListingViewController)
        
        viewModel = ImageListingViewModel(delegate: imageListingViewController)
        viewModel.searchText = ""
        viewModel.currentPageIndex = 1
        images = [ImageItem]()
        
        XCTAssertNotNil(viewModel)
    }
    
    override func tearDown() {

        super.tearDown()
        imageListingViewController = nil
        viewModel = nil
        images = nil
        
        XCTAssertNil(imageListingViewController)
        XCTAssertNil(viewModel)
        XCTAssertNil(images)
    }
    
    
    func test_viewModelAttributes() {
        XCTAssertTrue(viewModel.searchText.isEmpty)
        XCTAssertTrue(viewModel.images.count == 0)
        XCTAssertTrue(viewModel.currentPageIndex == 1)
        XCTAssertTrue(viewModel.isNextPageRequestInProgress == false)
    }
    
    func test_fetchImagesFromServer() {
        
        let asyncExpectation = expectation(description: "Network call to fetch image Items")
        viewModel.interactor?.updateRequestParameters(page: viewModel.currentPageIndex, searchText: "UBER")
        
        XCTAssertTrue(images.count == 0)
        
        viewModel.interactor?.getImageList(completion: {[weak self] (response) in
            
            switch response {
            case .success(let data):
                
                guard let weakSelf = self, let imageItems = data?.metadata.imageItems else {  return }
                weakSelf.images = imageItems
                
                XCTAssertTrue(weakSelf.images.count > 0)
            
            case .failure(let error):
                XCTAssertTrue(error.localizedDescription.isEmpty == false)
                
            }
            asyncExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 60) { (error) in
            if let error = error {
                XCTAssertNotNil(error, "Time out in fetching images")
            }
        }
    }
}
