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
    func call(url: NSURL, method: APIMethodType, data: [String: AnyObject]?, callback: ((result: AnyObject?, error: NSError?) -> Void))
}

/// Exiration object, used to define the cache experiation of a request
public class Expiration {

    internal var dateComponents: NSDateComponents?

    /// Create an expiration object that never expires
    public class func Never() -> Self {
        return self.init(dateComponents: nil)
    }

    /// Create an expiration object that expires in a number of seconds
    public convenience init(seconds: Int) {
        self.init(dateComponents: NSDateComponents())
        self.dateComponents?.second = seconds
    }

    /// Create an expiration object that expires in a number of minutes
    public convenience init(minutes: Int = 1) {
        self.init(dateComponents: NSDateComponents())
        self.dateComponents?.minute = minutes
    }

    /// Create an expiration object that expires in a number of hours
    public convenience init(hours: Int = 1) {
        self.init(dateComponents: NSDateComponents())
        self.dateComponents?.hour = hours
    }

    /// Create an expiration object that expires in a number of days
    public convenience init(days: Int = 1) {
        self.init(dateComponents: NSDateComponents())
        self.dateComponents?.day = days
    }

    /// Create an expiration object that expires in a number of weeks
    public convenience init(weeks: Int = 1) {
        self.init(dateComponents: NSDateComponents())
        // TODO: do all calanders have a 7 day week?
        self.dateComponents?.day = weeks*7
    }

    /// Create an expiration object that expires in a number of months
    public convenience init(months: Int = 1) {
        self.init(dateComponents: NSDateComponents())
        self.dateComponents?.month = months
    }

    /// Create an expiration object that expires in a number of years
    public convenience init(years: Int = 1) {
        self.init(dateComponents: NSDateComponents())
        self.dateComponents?.year = years
    }

    /// Create an expiration object that expires with date components object
    required public init(dateComponents: NSDateComponents?) {
        self.dateComponents = dateComponents
    }

}

public class API {

    private let cache: Cache
    private static let privateSharedConnection = API()

    private func request(url: NSURL, method: APIMethodType = .Get, data: [String: AnyObject]? = nil, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        if debugLevel == .Print {
            print("Request - url: '\(url)' method: '\(method)' data: '\(data)'")
        }

        guard let request = self.request else {
            let error = NSError(domain: APIErrorDomain, code: APINoRequestImplementationErrorCode,
                userInfo: [NSLocalizedDescriptionKey: "No API request implementation"]
            )
            callback(result: nil, error: error)
            return
        }

        request.call(url, method: method, data: data, callback: callback)
    }

    public convenience init() {
        self.init(cacheName: "api")
    }

    public init(cacheName: String) {
        self.cache = Cache(named: cacheName)
    }

    /// The request object to use
    public var request: APIRequest?

    /// The debug level, defaults to `None`
    public var debugLevel: DebugLebel = .None

    /// The shared connection singleton: `API.sharedConnection()`
    public static func sharedConnection() -> API {
        return self.privateSharedConnection
    }

    /// Clear the cache
    public func clearCache() {
        self.cache.clearCache()
    }

    /**
     GET request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter expiration: An optional expiration object that defines how long to cache the request.
     Defaults to nil. If nil, no caching occures.
     - Parameter callback: The method to call with with data or error from the request.
     */
    public func get(url: NSURL, data: [String: AnyObject]? = nil, expiration: Expiration? = nil, callback: ((result: AnyObject?, error: NSError?, resultLocation: ResultLocation?) -> Void)) {
        self.cache.objectForKey(url.absoluteString) { object, location in
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

            // Request the data from the server
            self.request(url, method: .Get, data: data) { object, error in
                if expiration != nil {
                    if let data = object where error == nil {
                        self.cache.setObject(data, forKey: url.absoluteString, expires: expiration?.dateComponents)
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
    public func put(url: NSURL, data: [String: AnyObject]? = nil, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        self.request(url, method: .Put, data: data, callback: callback)
    }

    /**
     POST request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter callback: The method to call with with data or error from the request.
     */
    public func post(url: NSURL, data: [String: AnyObject]? = nil, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        self.request(url, method: .Post, data: data, callback: callback)
    }

    /**
     DELETE request

     - Parameter url: The url for the request.
     - Parameter data: Additional data for the request.
     - Parameter callback: The method to call with with data or error from the request.
     */
    public func delete(url: NSURL, data: [String: AnyObject]? = nil, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        self.request(url, method: .Delete, data: data, callback: callback)
    }
    
}
