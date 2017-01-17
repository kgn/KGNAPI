//
//  URLSessionRequest.swift
//  KGNAPI
//
//  Created by David Keegan on 2/14/16.
//  Copyright © 2016 David Keegan. All rights reserved.
//

/// An APIRequest that wraps URLSession.
/// The result object sent to the callback is a data object from URLSession.
open class URLSessionAPIRequest: APIRequest {
    public init() {}
    
    public func call(url: URL, method: APIMethodType, headers: [String: Any]?, body: Data?, callback: @escaping ((_ result: Any?, _ error: Error?) -> Void)) {
        let session: URLSession!
        if headers == nil {
            session = URLSession.shared
        } else {
            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.httpAdditionalHeaders = headers
            session = URLSession(configuration: sessionConfiguration)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        session.dataTask(with: request, completionHandler: { (data, response, error) in
            callback(data, error)
        }).resume()
    }
    
}
