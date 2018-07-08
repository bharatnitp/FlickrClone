//
//  ImageListViewModelDelegate.swift
//  FlickrClone
//
//  Created by Bharat Bhushan on 07/07/18.
//  Copyright © 2018 Bharat Bhushan. All rights reserved.
//

import UIKit



//MARK: - ViewModel protocol
protocol ImageListViewModelDelegate: class {
    func updateImageList()
    func didFailToFetchImageList(message: String)
}

class ImageListViewModel {
    
    
    ///  number of columns to show in single row of collection view
    var numberOfColumns: Int {
        return 3
    }
    
    /// spcaing between each cell of image
    var minSpacingBetweenCells: Int {
        return 10
    }
    
    /// height of an image
    var cellheight: CGFloat {
        return 160
    }
    
    /// response model
    private var responseModel: ResponseModel?
    
    /// images array
    private(set) var images: [ImageItem]
    
    /// user input search text
    var searchText: String
    
    //current page index to lookup the images on server
    var currentPageIndex: Int
    
    /// Boolean to track whether an API call progress
    var isNextPageRequestInProgress: Bool
    
    /// interface to fetch the images from  source
    var interactor: ImageListInteractor?
    
    weak var delegate: ImageListViewModelDelegate?
    
    
    /// Initializer
    ///
    /// - Parameter delegate: delegate of view model
    
    required init(delegate: ImageListViewModelDelegate) {
        interactor = ImageListInteractor()
        images = [ImageItem]()
        self.delegate = delegate
        searchText = ""
        currentPageIndex = 1
        isNextPageRequestInProgress = false
    }
    
    
    /// Total images
    ///
    /// - Returns: total images count
    func totalNumberOfImages() -> Int {
        return images.count
    }
    
    
    /// ImageModel for a cell
    ///
    /// - Parameter
    /// - index: Integer type
    /// - Returns: image item (model)
    func getImageItem(at index: Int) -> ImageItem {
        return images[index]
    }
    
    
    /// Search images based on input text
    ///
    /// - Parameter searchText: input text
    func searchImages(forText searchText: String?) {
        isNextPageRequestInProgress = false
        if let searchText = searchText, self.searchText != searchText {
                self.searchText = searchText
                images.removeAll()
                if !searchText.isEmpty {
                    currentPageIndex = 1
                    getImageList()
                }
        } else {
            if self.searchText.isEmpty == false {
                self.searchText = ""
                images.removeAll()
            }
        }
    }
    
    
    /// Search image when user has scrolled to bottom of the screen
    ///
    /// - Returns: Boolean (to track the current API call progress)
    func searchImagesForNextPage() -> Bool {
        var isRequestStarted = false
        if (isNextPageRequestInProgress == false) && (self.searchText.isEmpty == false) {
            if let responseModel = responseModel, let totalPages = Int(responseModel.metadata.total), totalPages > currentPageIndex {
                currentPageIndex += 1
                isNextPageRequestInProgress = true
                isRequestStarted = true
                getImageList()
            }
        }
        return isRequestStarted
    }
    
    
    /// note : - API call to fetch new images from server
    /// on success update the UI with updated image list and
    /// on error show the alert to user if user is on 1st page
    ///
    
    private func getImageList() {
        
        interactor?.updateRequestParameters(page: currentPageIndex, searchText: searchText)
        
        interactor?.getImageList(completion: {[weak self] (response) in
            
            guard let weakSelf = self else { return }
            weakSelf.isNextPageRequestInProgress = false
            switch response {
            
            case .success(let dataModel):
                
                if let images = dataModel?.metadata.imageItems {
                    weakSelf.images.append(contentsOf: images)
                }
                if weakSelf.currentPageIndex == 1 {
                    weakSelf.responseModel = dataModel
                }
                weakSelf.delegate?.updateImageList()
            
            case .failure(let error):
                if weakSelf.currentPageIndex > 1 {
                    weakSelf.currentPageIndex -= 1
                }
                weakSelf.delegate?.didFailToFetchImageList(message: error.localizedDescription)
            }
        })
    }
}
