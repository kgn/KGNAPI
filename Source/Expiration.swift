//
//  Expiration.swift
//  KGNAPI
//
//  Created by David Keegan on 1/30/16.
//  Copyright © 2016 David Keegan. All rights reserved.
//

import Foundation

/// Exiration object, used to define the cache experiation of a request
public class Expiration {

    /// Determins if the APIRequest call should
    /// be made if a cached object already exists.
    public let shouldRequestIfAlreadyInCache: Bool

    /// The underlying date components object.
    public var dateComponents: DateComponents?

    /// Create an expiration object that never expires
    public class func Never(shouldRequestIfAlreadyInCache: Bool = true) -> Self {
        return self.init(dateComponents: nil, shouldRequestIfAlreadyInCache: shouldRequestIfAlreadyInCache)
    }

    /// Create an expiration object that expires in a number of seconds
    public convenience init(seconds: Int, shouldRequestIfAlreadyInCache: Bool = true) {
        self.init(dateComponents: DateComponents(), shouldRequestIfAlreadyInCache: shouldRequestIfAlreadyInCache)
        self.dateComponents?.second = seconds
    }

    /// Create an expiration object that expires in a number of minutes
    public convenience init(minutes: Int = 1, shouldRequestIfAlreadyInCache: Bool = true) {
        self.init(dateComponents: DateComponents(), shouldRequestIfAlreadyInCache: shouldRequestIfAlreadyInCache)
        self.dateComponents?.minute = minutes
    }

    /// Create an expiration object that expires in a number of hours
    public convenience init(hours: Int = 1, shouldRequestIfAlreadyInCache: Bool = true) {
        self.init(dateComponents: DateComponents(), shouldRequestIfAlreadyInCache: shouldRequestIfAlreadyInCache)
        self.dateComponents?.hour = hours
    }

    /// Create an expiration object that expires in a number of days
    public convenience init(days: Int = 1, shouldRequestIfAlreadyInCache: Bool = true) {
        self.init(dateComponents: DateComponents(), shouldRequestIfAlreadyInCache: shouldRequestIfAlreadyInCache)
        self.dateComponents?.day = days
    }

    /// Create an expiration object that expires in a number of weeks
    public convenience init(weeks: Int = 1, shouldRequestIfAlreadyInCache: Bool = true) {
        self.init(dateComponents: DateComponents(), shouldRequestIfAlreadyInCache: shouldRequestIfAlreadyInCache)
        // TODO: do all calanders have a 7 day week?
        self.dateComponents?.day = weeks*7
    }

    /// Create an expiration object that expires in a number of months
    public convenience init(months: Int = 1, shouldRequestIfAlreadyInCache: Bool = true) {
        self.init(dateComponents: DateComponents(), shouldRequestIfAlreadyInCache: shouldRequestIfAlreadyInCache)
        self.dateComponents?.month = months
    }

    /// Create an expiration object that expires in a number of years
    public convenience init(years: Int = 1, shouldRequestIfAlreadyInCache: Bool = true) {
        self.init(dateComponents: DateComponents(), shouldRequestIfAlreadyInCache: shouldRequestIfAlreadyInCache)
        self.dateComponents?.year = years
    }

    /// Create an expiration object that expires with date components object
    required public init(dateComponents: DateComponents?, shouldRequestIfAlreadyInCache: Bool = true) {
        self.dateComponents = dateComponents
        self.shouldRequestIfAlreadyInCache = shouldRequestIfAlreadyInCache
    }
    
}
