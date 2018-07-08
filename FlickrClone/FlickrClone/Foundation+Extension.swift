//
//  Foundation+Extension.swift
//  FlickrClone
//
//  Created by Bharat Bhushan on 07/07/18.
//  Copyright © 2018 Bharat Bhushan. All rights reserved.
//

import Foundation
import UIKit

extension URL {
    func addQueryParameters(_ page: Int, andSearchText searchText: String) -> URL? {
        guard let components = NSURLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        guard var queryItems = components.queryItems else { return nil }
        queryItems = queryItems.filter {$0.name != "text"}
        queryItems = queryItems.filter {$0.name != "page"}
        let pageQueryItem = URLQueryItem(name: "page", value: String(page))
        let textQueryItem = URLQueryItem(name: "text", value: searchText)
        queryItems.append(textQueryItem)
        queryItems.append(pageQueryItem)

        components.queryItems = queryItems
        return components.url
    }
}

extension UIViewController {
    func showAlert(withTitle title: String?, message: String) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAlertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(cancelAlertAction)
        present(alertController, animated: true, completion: nil)
    }
}


