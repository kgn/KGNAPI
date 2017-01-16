//
//  API.swift
//  KGNAPI
//
//  Created by David Keegan on 1/24/15.
//  Copyright (c) 2014 David Keegan. All rights reserved.
//

import Foundation
import KGNCache

enum APIError: Error {
    case noRequest
    
    var localizedDescription: String {
        switch self {
            case .noRequest: return "No API request implementation"
        }
    }
}

/// API method types: PUT, POST, GET, DELETE
public enum APIMethodType: String {
    case put = "PUT"
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
}

/// API debug level: none or print all requests
public enum DebugLebel {
    case none
    case print
}

/// The location of where the result came from
public enum ResultLocation {
    case memory
    case disk
    case api
}

/// Implement this protocal to configure the network requests.
public protocol APIRequest {
    func call(url: URL, method: APIMethodType, headers: [String: Any]?, body: Data?, callback: @escaping ((_ result: Any?, _ error: Error?) -> Void))
}

open class API {

    private let cache: KGNCache.Cache

    private func request(url: URL, method: APIMethodType = .get, headers: [String: Any]? = nil, body: Data? = nil, callback: @escaping ((_ result: Any?, _ error: Error?) -> Void)) {
        if self.debugLevel == .print {
            print("Request - url: '\(url)' method: '\(method)' headers: '\(headers)' body: '\(body)'")
        }

        guard let request = self.request else {
            callback(nil, APIError.noRequest)
            return
        }

        request.call(url: url, method: method, headers: headers, body: body, callback: callback)
    }

    internal func cacheName(url: URL, headers: [String: Any]?, body: Data?) -> String {
        // TODO: use headers and body
        return url.absoluteString
    }

    public convenience init() {
        self.init(cacheName: "api")
    }

    public required init(cacheName: String) {
        self.cache = KGNCache.Cache(named: cacheName)
    }

    /// The request object to use
    open var request: APIRequest?

    /// The debug level, defaults to `none`
    open var debugLevel: DebugLebel = .none

    /// Clear the cache
    open func clearCache() {
        self.cache.clear()
    }

    /// Converts a dictionary object to a json data object
    open class func JSONData(_ body: [String: Any]?) -> Data? {
        if body != nil {
            return try? JSONSerialization.data(withJSONObject: body!, options: [])
        }
        return nil
    }

    /**
     GET request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter expiration: An optional expiration object that defines how long to cache the request.
     Defaults to nil. If nil, no caching occures.
     - Parameter callback: The method to call with with data or error from the request.
     */
    open func get(url: URL, headers: [String: Any]? = nil, body: Data? = nil, expiration: Expiration? = nil, callback: @escaping ((_ result: Any?, _ error: Error?, _ resultLocation: ResultLocation?) -> Void)) {
        let key = self.cacheName(url: url, headers: headers, body: body)
        self.cache.object(forKey: key) { object, location in
            // Call the callback if the object is in the cache
            if let data = object {
                var resultLocation: ResultLocation?
                if location == .memory {
                    resultLocation = .memory
                } else if location == .disk {
                    resultLocation = .disk
                }
                callback(data, nil, resultLocation)
            }

            // If we have an object, and the expiration
            // should not request from the server, than early exit
            if object != nil && expiration?.shouldRequestIfAlreadyInCache == false {
                return
            }

            // Request the data from the server
            self.request(url: url, method: .get, headers: headers, body: body) { [weak self] object, error in
                if expiration != nil {
                    if let data = object, error == nil {
                        self?.cache.set(object: data as AnyObject, forKey: key, expires: expiration?.dateComponents)
                    }
                }
                callback(object, error, .api)
            }
        }
    }

    /**
     PUT request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter callback: The method to call with with data or error from the request.
     */
    open func put(url: URL, headers: [String: Any]? = nil, body: Data? = nil, callback: @escaping ((_ result: Any?, _ error: Error?) -> Void)) {
        self.request(url: url, method: .put, headers: headers, body: body, callback: callback)
    }

    /**
     POST request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter callback: The method to call with with data or error from the request.
     */
    open func post(url: URL, headers: [String: Any]? = nil, body: Data? = nil, callback: @escaping ((_ result: Any?, _ error: Error?) -> Void)) {
        self.request(url: url, method: .post, headers: headers, body: body, callback: callback)
    }

    /**
     DELETE request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter callback: The method to call with with data or error from the request.
     */
    open func delete(url: URL, headers: [String: Any]? = nil, body: Data? = nil, callback: @escaping ((_ result: Any?, _ error: Error?) -> Void)) {
        self.request(url: url, method: .delete, headers: headers, body: body, callback: callback)
    }
    
}
