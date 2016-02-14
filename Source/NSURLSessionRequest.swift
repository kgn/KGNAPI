//
//  NSURLSessionRequest.swift
//  KGNAPI
//
//  Created by David Keegan on 2/14/16.
//  Copyright © 2016 David Keegan. All rights reserved.
//

// An APIRequest that wraps NSURLSession
public class NSURLSessionRequest: APIRequest {

    public func call(url: NSURL, method: APIMethodType, headers: [String: AnyObject]?, body: NSData?, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.HTTPAdditionalHeaders = headers

        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
        request.HTTPBody = body

        NSURLSession(configuration: sessionConfiguration).dataTaskWithRequest(request, completionHandler: { data, response, error in
            if data != nil {
                callback(result: try? NSJSONSerialization.JSONObjectWithData(data!, options: []), error: error)
            } else {
                callback(result: nil, error: error)
            }
        }).resume()
    }
    
}