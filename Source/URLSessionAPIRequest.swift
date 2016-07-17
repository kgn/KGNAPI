//
//  URLSessionRequest.swift
//  KGNAPI
//
//  Created by David Keegan on 2/14/16.
//  Copyright © 2016 David Keegan. All rights reserved.
//

/// An APIRequest that wraps URLSession.
/// The result object sent to the callback is a data object from URLSession.
public class URLSessionAPIRequest: APIRequest {

    public init() {}

    public func call(url: URL, method: APIMethodType, headers: [String: AnyObject]?, body: Data?, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        let sessionConfiguration = URLSessionConfiguration.default()
        sessionConfiguration.httpAdditionalHeaders = headers

        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        let session = URLSession(configuration: sessionConfiguration)
        session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            callback(result: data, error: error)
        }).resume()
    }
    
}
