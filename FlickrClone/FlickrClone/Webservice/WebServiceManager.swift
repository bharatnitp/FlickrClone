//
//  WebServiceManager.swift
//  FlickrClone
//
//  Created by Bharat Bhushan on 07/07/18.
//  Copyright © 2018 Bharat Bhushan. All rights reserved.
//


import UIKit


/// API Response
///
/// - success: Success response generic type
/// - failure: Error, which contains localized descrition of error

enum Response<T, E> where E: Error {
    case success(T)
    case failure(E)
}


/// Error types

enum APIError: Error {
    
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case jsonParsingFailure
    var localizedDescription: String {
        switch self {
        case .requestFailed: return "Request Failed"
        case .invalidData: return "Invalid Data"
        case .responseUnsuccessful: return "Response Unsuccessful"
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .jsonConversionFailure: return "JSON Conversion Failure"
        }
    }
}

enum HTTPMethod {
    case get
    case post([String:Any])
    case put([String:Any])
    case delete
}

extension HTTPMethod {
    var type:String{
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .delete: return "DELETE"
        }
    }
    
}


/// HTTP request protocol
protocol APIRequest {
    var url: URL? { get set }
    var httpMethod: HTTPMethod { get }
    var requestBody: Data? { get }
    var headers: [String: String]? { get }
}


// MARK: - HTTP request protocol extension
extension APIRequest {
    
    var request: URLRequest {
        var request = URLRequest(url: url!)
        request.httpMethod = httpMethod.type
        request.httpBody = requestBody
        request.allHTTPHeaderFields = headers
        return request
    }
}



protocol WebServiceManager {
    
    func fetch<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (Response<T, APIError>) -> Void)
    func fetchImage(with request: URLRequest, completion: @escaping (Response<Data?, APIError>) -> Void)
}

let session: URLSession = URLSession(configuration: .default)

extension WebServiceManager {
    
    typealias completionHandler = (Decodable?, APIError?) -> Void
    typealias imageCompletionHandler = (Data?, APIError?) -> Void
    
    
    /// Data Download task
    ///
    /// - Parameters:
    ///   - request: HTTP Request
    ///   - decodingType: model class or struct which must conform to Decodable protocol
    ///   - completion: JSON response
    /// - Returns: Data task
    
    private func downloadTask<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping completionHandler) -> URLSessionDataTask {
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            if httpResponse.statusCode == 200, error == nil {
                if let data = data {
                    do {
                        let genericModel = try JSONDecoder().decode(decodingType, from: data)
                        completion(genericModel, nil)
                    } catch {
                        completion(nil, .jsonConversionFailure)
                    }
                } else {
                    completion(nil, .invalidData)
                }
            } else {
                completion(nil, .responseUnsuccessful)
            }
        }
        return task
    }
    
    
    /// Image data download task
    ///
    /// - Parameters:
    ///   - request: HTTP Request
    ///   - completion: JSON response
    /// - Returns: Download image task
    
    private func downloadImageTask(with request: URLRequest, completionHandler completion: @escaping imageCompletionHandler) -> URLSessionDataTask {
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            if httpResponse.statusCode == 200, error == nil {
                if let data = data {
                    completion(data, nil)
                } else {
                    completion(nil, .invalidData)
                }
            } else {
                completion(nil, .responseUnsuccessful)
            }
        }
        return task
    }
    
    
    /// HTTP request to fetch data from server
    ///
    /// - Parameters:
    ///   - request: HTTPRequest
    ///   - decode: model class or struct which must conform to Decodable protocol
    ///   - completion: JSON response
    
    func fetch<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (Response<T, APIError>) -> Void) {
        
        let task = downloadTask(with: request, decodingType: T.self) { (json , error) in
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(Response.failure(error))
                    } else {
                        completion(Response.failure(.invalidData))
                    }
                    return
                }
                if let value = decode(json) {
                    completion(.success(value))
                } else {
                    completion(.failure(.jsonParsingFailure))
                }
            }
        }
        task.resume()
    }
    
    /// HTTP request to fetch image data from server
    ///
    /// - Parameters:
    ///   - request: HTTPRequest
    ///   - completion: JSON response
    
    func fetchImage(with request: URLRequest, completion: @escaping (Response<Data?, APIError>) -> Void) {
        let task = downloadImageTask(with: request) { (json , error) in
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(Response.failure(error))
                    } else {
                        completion(Response.failure(.invalidData))
                    }
                    return
                }
                completion(.success(json))
            }
        }
        task.resume()
    }
}
