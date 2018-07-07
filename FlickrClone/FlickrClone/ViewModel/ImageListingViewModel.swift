//
//  ImageListingViewModelDelegate.swift
//  FlickrClone
//
//  Created by Bharat Bhushan on 07/07/18.
//  Copyright © 2018 Bharat Bhushan. All rights reserved.
//

import UIKit

protocol ImageListingViewModelDelegate: class {
    func updateImageListing()
    func didFailToFetchImageList(message: String)
}

class ImageListingViewModel {
    
    
    var numberOfColumns: Int {
        return 3
    }
    var minSpacingBetweenCells: Int {
        return 10
    }
    
    var cellheight: CGFloat {
        return 160
    }
    
    private var responseModel: ResponseModel?
    private(set) var images: [ImageItem]
    var searchText: String
    var curentPageIndex: Int
    fileprivate var isNextPageRequestInProgress: Bool
    fileprivate var interactor: ImageListingInteractor?
    weak var delegate: ImageListingViewModelDelegate?
    
    
    required init(delegate: ImageListingViewModelDelegate) {
        interactor = ImageListingInteractor()
        images = [ImageItem]()
        self.delegate = delegate
        searchText = ""
        curentPageIndex = 1
        isNextPageRequestInProgress = false
    }
    
    func totalNumberOfImages() -> Int {
        return images.count
    }
    
    func getImageItem(at index: Int) -> ImageItem {
        return images[index]
    }
    
    func searchImages(forText searchText: String?) {
        isNextPageRequestInProgress = false
        if let searchText = searchText, self.searchText != searchText {
                self.searchText = searchText
                images.removeAll()
                if !searchText.isEmpty {
                    curentPageIndex = 1
                    getImageList()
                }
        } else {
            if self.searchText.isEmpty == false {
                self.searchText = ""
                images.removeAll()
            }
        }
    }
    
    func searchImagesForNextPage() -> Bool {
        var isRequestStarted = false
        if (isNextPageRequestInProgress == false) && (self.searchText.isEmpty == false) {
            if let responseModel = responseModel, let totalPages = Int(responseModel.metadata.total), totalPages > curentPageIndex {
                curentPageIndex += 1
                isNextPageRequestInProgress = true
                isRequestStarted = true
                getImageList()
            }
        }
        return isRequestStarted
    }
    
    private func getImageList() {
        
        interactor?.updateRequestParameters(page: curentPageIndex, searchText: searchText)
        
        interactor?.getImageList(completion: {[weak self] (response) in
            
            guard let weakSelf = self else { return }
            weakSelf.isNextPageRequestInProgress = false
            switch response {
            
            case .success(let dataModel):
                
                if let images = dataModel?.metadata.imageItems {
                    weakSelf.images.append(contentsOf: images)
                }
                if weakSelf.curentPageIndex == 1 {
                    weakSelf.responseModel = dataModel
                }
                weakSelf.delegate?.updateImageListing()
            
            case .failure(let error):
                if weakSelf.curentPageIndex > 1 {
                    weakSelf.curentPageIndex -= 1
                }
                weakSelf.delegate?.didFailToFetchImageList(message: error.localizedDescription)
            }
        })
    }
}
