//
//  ImageCollectionViewCell.swift
//  FlickrClone
//
//  Created by Bharat Bhushan on 07/07/18.
//  Copyright © 2018 Bharat Bhushan. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell, WebServiceManager {
    
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    let placeholderImage: UIImage = UIImage(named: "placeholder")!
    var requestedImageURL: URL?
    var imageCacheManager = ImageCacheManager()
    
    override func awakeFromNib() {
        imageView.image = placeholderImage
        titleTextLabel.text = ""
    }
    
    func configureCell(with model: ImageItem) {
        resetUI()
        imageView.image = placeholderImage
        titleTextLabel.text = model.title
        if let url = model.getImageUrl() {
            requestedImageURL = url
            imageCacheManager.loadImage(imageId: model.id, url: url, completion: {[weak self] (response) in
                switch response {
                case .success(let data):
                    guard let weakSelf = self, let imageData = data else { return }
                    if url != weakSelf.requestedImageURL {
                        weakSelf.imageView.image = weakSelf.placeholderImage
                    } else {
                        weakSelf.imageView.image = UIImage(data: imageData)
                        weakSelf.imageCacheManager.cacheImage(imageId: model.id, imageData: imageData)
                    }
                case .failure:
                   self?.imageView.image = self?.placeholderImage
                   self?.titleTextLabel.text = ""
                }
            })
        }
    }
    
    private func resetUI() {
        requestedImageURL = nil
        imageView.image = placeholderImage
    }
}
