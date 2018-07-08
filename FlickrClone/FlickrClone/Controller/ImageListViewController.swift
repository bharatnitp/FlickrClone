//
//  ImageListViewController.swift
//  FlickrClone
//
//  Created by Bharat Bhushan on 05/07/18.
//  Copyright © 2018 Bharat Bhushan. All rights reserved.
//

import UIKit

class ImageListViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var viewModel: ImageListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ImageListViewModel(delegate: self)
        configureSearchbar()
        registerCells()
    }
    
    private func configureSearchbar() {
        searchBar.delegate = self
        searchBar.barStyle = .blackTranslucent
        searchBar.placeholder = "photos, people or groups"
    }
    
    private func registerCells() {
        let cellNib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: "imageCellIdentifier")
    }
}

//MARK: CollectionView delegate and datasource methods

extension ImageListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.totalNumberOfImages()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageItem = viewModel.getImageItem(at: indexPath.row)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCellIdentifier", for: indexPath) as! ImageCollectionViewCell
        cell.configureCell(with: imageItem)
        cell.layoutIfNeeded()
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout method to calculate the size of an item

extension ImageListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfColumns = viewModel.numberOfColumns
        if numberOfColumns == 0 {
            return  CGSize.zero
        }
        
        let minSpacing = viewModel.minSpacingBetweenCells
        let cellHeight = viewModel.cellheight
        let totalWidth = view.frame.width - 16
        let totalPadding = (numberOfColumns + 1) * minSpacing
        let widthWithoutPadding = Int(totalWidth) - totalPadding
        let cellWidth = widthWithoutPadding/numberOfColumns
        return  CGSize(width: CGFloat(cellWidth), height: cellHeight)
    }
}

//MARK:- UISearchBarDelegate Search Bar delegate methods

extension ImageListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text, !text.isEmpty, viewModel.searchText != text {
            activityIndicator.startAnimating()
            collectionView.reloadData()
            viewModel.searchImages(forText: text)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if viewModel.totalNumberOfImages() > 0 {
            viewModel.searchImages(forText: searchText)
            collectionView.reloadData()
        }
    }
}

//MARK:- UIScrollViewDelegate method to handle auto scrolling

extension ImageListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            let isRequestStarted = viewModel.searchImagesForNextPage()
            if isRequestStarted == true {
                activityIndicator.startAnimating()
            }
        }
    }
}

//MARK: ViewModel delegate method

extension ImageListViewController: ImageListViewModelDelegate {
    func updateImageList() {
        activityIndicator.stopAnimating()
        if viewModel.totalNumberOfImages() == 0 {
            showAlert(withTitle: nil, message: "No results found")
        } else {
            collectionView.reloadData()
        }
    }
    
    func didFailToFetchImageList(message: String) {
        activityIndicator.stopAnimating()
        if viewModel.currentPageIndex == 1 {
            let title: String = "Error"
            showAlert(withTitle: title, message: message)
        }
    }
}

