//
//  API.swift
//  KGNAPI
//
//  Created by David Keegan on 1/24/15.
//  Copyright (c) 2014 David Keegan. All rights reserved.
//

import Foundation
import KGNCache

/// The API error domain
public let APIErrorDomain = "kgn.api.error"

/// The API error code for if no request has been implremented
public let APINoRequestImplementationErrorCode = -1

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
    func call(url: URL, method: APIMethodType, headers: [String: AnyObject]?, body: Data?, callback: ((result: AnyObject?, error: NSError?) -> Void))
}

public class API {

    private let cache: KGNCache.Cache

    private func request(url: URL, method: APIMethodType = .get, headers: [String: AnyObject]? = nil, body: Data? = nil, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        if debugLevel == .print {
            print("Request - url: '\(url)' method: '\(method)' headers: '\(headers)' body: '\(body)'")
        }

        guard let request = self.request else {
            let error = NSError(domain: APIErrorDomain, code: APINoRequestImplementationErrorCode,
                userInfo: [NSLocalizedDescriptionKey: "No API request implementation"]
            )
            callback(result: nil, error: error)
            return
        }

        request.call(url: url, method: method, headers: headers, body: body, callback: callback)
    }

    internal func cacheName(url: URL, headers: [String: AnyObject]?, body: Data?) -> String {
        // TODO: use headers and body
        return url.absoluteString!
    }

    public convenience init() {
        self.init(cacheName: "api")
    }

    public required init(cacheName: String) {
        self.cache = KGNCache.Cache(named: cacheName)
    }

    /// The request object to use
    public var request: APIRequest?

    /// The debug level, defaults to `None`
    public var debugLevel: DebugLebel = .none

    /// The shared connection singleton: `API.sharedConnection()`
    public class func sharedConnection() -> API {
        struct Static {
            static let instance = API()
        }
        return Static.instance
    }
    
//    /// The shared connection singleton: `API.sharedConnection`
//    public static func sharedConnection() -> Self {
//        return self.init()
//    }

    /// Clear the cache
    public func clearCache() {
        self.cache.clear()
    }

    /// Converts a dictionary object to a json data object
    public class func JSONData(body: [String: AnyObject]?) -> Data? {
        if body == nil {
            return nil
        }
        return try? JSONSerialization.data(withJSONObject: body!, options: [])
    }

    /**
     GET request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter expiration: An optional expiration object that defines how long to cache the request.
     Defaults to nil. If nil, no caching occures.
     - Parameter callback: The method to call with with data or error from the request.
     */
    public func get(url: URL, headers: [String: AnyObject]? = nil, body: Data? = nil, expiration: Expiration? = nil, callback: ((result: AnyObject?, error: NSError?, resultLocation: ResultLocation?) -> Void)) {
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
                callback(result: data, error: nil, resultLocation: resultLocation)
            }

            // If we have an object, and the expiration
            // should not request from the server, than early exit
            if object != nil && expiration?.shouldRequestIfAlreadyInCache == false {
                return
            }

            // Request the data from the server
            self.request(url: url, method: .get, headers: headers, body: body) { [weak self] object, error in
                if expiration != nil {
                    if let data = object where error == nil {
                        self?.cache.set(object: data, forKey: key, expires: expiration?.dateComponents)
                    }
                }
                callback(result: object, error: error, resultLocation: .api)
            }
        }
    }

    /**
     PUT request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter callback: The method to call with with data or error from the request.
     */
    public func put(url: URL, headers: [String: AnyObject]? = nil, body: Data? = nil, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        self.request(url: url, method: .put, headers: headers, body: body, callback: callback)
    }

    /**
     POST request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter callback: The method to call with with data or error from the request.
     */
    public func post(url: URL, headers: [String: AnyObject]? = nil, body: Data? = nil, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        self.request(url: url, method: .post, headers: headers, body: body, callback: callback)
    }

    /**
     DELETE request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter callback: The method to call with with data or error from the request.
     */
    public func delete(url: URL, headers: [String: AnyObject]? = nil, body: Data? = nil, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        self.request(url: url, method: .delete, headers: headers, body: body, callback: callback)
    }
    
}
