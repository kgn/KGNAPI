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
    case Put = "PUT"
    case Post = "POST"
    case Get = "GET"
    case Delete = "DELETE"
}

/// API debug level: none or print all requests
public enum DebugLebel {
    case None
    case Print
}

/// The location of where the result came from
public enum ResultLocation {
    case Memory
    case Disk
    case API
}

/// Implement this protocal to configure the network requests.
public protocol APIRequest {
    func call(url: NSURL, method: APIMethodType, headers: [String: AnyObject]?, body: NSData?, callback: ((result: AnyObject?, error: NSError?) -> Void))
}

public class API {

    private let cache: Cache

    private func request(url: NSURL, method: APIMethodType = .Get, headers: [String: AnyObject]? = nil, body: NSData? = nil, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        if debugLevel == .Print {
            print("Request - url: '\(url)' method: '\(method)' headers: '\(headers)' body: '\(body)'")
        }

        guard let request = self.request else {
            let error = NSError(domain: APIErrorDomain, code: APINoRequestImplementationErrorCode,
                userInfo: [NSLocalizedDescriptionKey: "No API request implementation"]
            )
            callback(result: nil, error: error)
            return
        }

        request.call(url, method: method, headers: headers, body: body, callback: callback)
    }

    internal func cacheName(url: NSURL, headers: [String: AnyObject]?, body: NSData?) -> String {
        // TODO: use headers and body
        return url.absoluteString
    }

    public convenience init() {
        self.init(cacheName: "api")
    }

    public required init(cacheName: String) {
        self.cache = Cache(named: cacheName)
    }

    /// The request object to use
    public var request: APIRequest?

    /// The debug level, defaults to `None`
    public var debugLevel: DebugLebel = .None

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
        self.cache.clearCache()
    }

    /// Converts a dictionary object to a json data object
    public class func JSONData(body: [String: AnyObject]?) -> NSData? {
        if body == nil {
            return nil
        }
        return try? NSJSONSerialization.dataWithJSONObject(body!, options: [])
    }

    /**
     GET request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter expiration: An optional expiration object that defines how long to cache the request.
     Defaults to nil. If nil, no caching occures.
     - Parameter callback: The method to call with with data or error from the request.
     */
    public func get(url: NSURL, headers: [String: AnyObject]? = nil, body: NSData? = nil, expiration: Expiration? = nil, callback: ((result: AnyObject?, error: NSError?, resultLocation: ResultLocation?) -> Void)) {
        let key = self.cacheName(url, headers: headers, body: body)
        self.cache.objectForKey(key) { object, location in
            // Call the callback if the object is in the cache
            if let data = object {
                var resultLocation: ResultLocation?
                if location == .Memory {
                    resultLocation = .Memory
                } else if location == .Disk {
                    resultLocation = .Disk
                }
                callback(result: data, error: nil, resultLocation: resultLocation)
            }

            // If we have an object, and the expiration
            // should not request from the server, than early exit
            if object != nil && expiration?.shouldRequestIfAlreadyInCache == false {
                return
            }

            // Request the data from the server
            self.request(url, method: .Get, headers: headers, body: body) { [weak self] object, error in
                if expiration != nil {
                    if let data = object where error == nil {
                        self?.cache.setObject(data, forKey: key, expires: expiration?.dateComponents)
                    }
                }
                callback(result: object, error: error, resultLocation: .API)
            }
        }
    }

    /**
     PUT request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter callback: The method to call with with data or error from the request.
     */
    public func put(url: NSURL, headers: [String: AnyObject]? = nil, body: NSData? = nil, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        self.request(url, method: .Put, headers: headers, body: body, callback: callback)
    }

    /**
     POST request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter callback: The method to call with with data or error from the request.
     */
    public func post(url: NSURL, headers: [String: AnyObject]? = nil, body: NSData? = nil, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        self.request(url, method: .Post, headers: headers, body: body, callback: callback)
    }

    /**
     DELETE request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter callback: The method to call with with data or error from the request.
     */
    public func delete(url: NSURL, headers: [String: AnyObject]? = nil, body: NSData? = nil, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        self.request(url, method: .Delete, headers: headers, body: body, callback: callback)
    }
    
}
