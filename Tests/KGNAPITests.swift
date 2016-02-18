//
//  KGNAPITests.swift
//  KGNAPITests
//
//  Created by David Keegan on 1/24/15.
//  Copyright © 2015 David Keegan. All rights reserved.
//

import XCTest
import KGNThread
@testable import KGNAPI

class TestRequest: APIRequest {

    func call(url: NSURL, method: APIMethodType, headers: [String: AnyObject]? = nil, body: NSData? = nil, callback: ((result: AnyObject?, error: NSError?) -> Void)) {
        Thread.Global.Background(delay: Double(arc4random_uniform(50))*0.01) {

            if method == .Put {
                if url.absoluteString == "user" {
                    callback(result: ["name": "Steve Wozniak", "company": "Apple", "year_of_birth": 1950], error: nil)
                }
                if url.absoluteString == "car" {
                    callback(result: ["company": "Porsche", "model": "GT3", "year": 2014], error: nil)
                }
                if url.absoluteString == "body" {
                    callback(result: try? NSJSONSerialization.JSONObjectWithData(body!, options: []), error: nil)
                }
                if url.absoluteString == "headers" {
                    callback(result: headers, error: nil)
                }
                if url.absoluteString == "error" {
                    callback(result: nil, error: NSError(domain: "test.kgn.api.error.put", code: -1, userInfo: nil))
                }
            }

            if method == .Post {
                if url.absoluteString == "user" {
                    callback(result: ["name": "Bill Gates", "company": "Microsoft", "year_of_birth": 1955], error: nil)
                }
                if url.absoluteString == "car" {
                    callback(result: ["company": "Porsche", "model": "911", "year": 2008], error: nil)
                }
                if url.absoluteString == "body" {
                    callback(result: try? NSJSONSerialization.JSONObjectWithData(body!, options: []), error: nil)
                }
                if url.absoluteString == "headers" {
                    callback(result: headers, error: nil)
                }
                if url.absoluteString == "error" {
                    callback(result: nil, error: NSError(domain: "test.kgn.api.error.post", code: -1, userInfo: nil))
                }
            }

            if method == .Get {
                if url.absoluteString == "user" {
                    callback(result: ["name": "Steve Jobs", "company": "Apple", "year_of_birth": 1955], error: nil)
                }
                if url.absoluteString == "car" {
                    callback(result: ["company": "Audi", "model": "Q5", "year": 2016], error: nil)
                }
                if url.absoluteString == "body" {
                    callback(result: try? NSJSONSerialization.JSONObjectWithData(body!, options: []), error: nil)
                }
                if url.absoluteString == "headers" {
                    callback(result: headers, error: nil)
                }
                if url.absoluteString == "error" {
                    callback(result: nil, error: NSError(domain: "test.kgn.api.error.get", code: -1, userInfo: nil))
                }
            }

            if method == .Delete {
                if url.absoluteString == "user" {
                    callback(result: [], error: nil)
                }
                if url.absoluteString == "car" {
                    callback(result: nil, error: nil)
                }
                if url.absoluteString == "body" {
                    callback(result: try? NSJSONSerialization.JSONObjectWithData(body!, options: []), error: nil)
                }
                if url.absoluteString == "headers" {
                    callback(result: headers, error: nil)
                }
                if url.absoluteString == "error" {
                    callback(result: nil, error: NSError(domain: "test.kgn.api.error.delete", code: -1, userInfo: nil))
                }
            }

        }
    }

}

class KGNAPIEarthQuackRequest: XCTestCase {

    override func setUp() {
        super.setUp()

        API.sharedConnection().request = NSURLSessionAPIRequest()
        API.sharedConnection().clearCache()
    }

    func testGetCount() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().get(NSURL(string: "http://earthquake.usgs.gov/fdsnws/event/1/count?format=geojson")!) { result, error, location in
            let json = try? NSJSONSerialization.JSONObjectWithData(result as! NSData, options: [])
            XCTAssertNotNil(json?["count"])
            XCTAssertNotNil(json?["maxAllowed"])
            XCTAssertEqual(location, .API)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)
    }

}

class KGNAPITestExpiration: XCTestCase {

    func testShouldRequestIfAlreadyInCache() {
        XCTAssertEqual(Expiration(seconds: 12).shouldRequestIfAlreadyInCache, true)
        XCTAssertEqual(Expiration(seconds: 12, shouldRequestIfAlreadyInCache: false).shouldRequestIfAlreadyInCache, false)
    }

    func testNever() {
        let expiration = Expiration.Never()
        XCTAssertNil(expiration.dateComponents)
    }

    func testSeconds() {
        let value = 12
        let expiration = Expiration(seconds: value)

        let dateComponents = NSDateComponents()
        dateComponents.second = value

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

    func testMinutes() {
        let value = 32
        let expiration = Expiration(minutes: value)

        let dateComponents = NSDateComponents()
        dateComponents.minute = value

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

    func testHours() {
        let value = 6
        let expiration = Expiration(hours: value)

        let dateComponents = NSDateComponents()
        dateComponents.hour = value

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

    func testDays() {
        let value = 4
        let expiration = Expiration(days: value)

        let dateComponents = NSDateComponents()
        dateComponents.day = value

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

    func testWeeks() {
        let value = 6
        let expiration = Expiration(weeks: value)

        let dateComponents = NSDateComponents()
        dateComponents.day = value*7

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

    func testMonths() {
        let value = 2
        let expiration = Expiration(months: value)

        let dateComponents = NSDateComponents()
        dateComponents.month = value

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

    func testYears() {
        let value = 7
        let expiration = Expiration(years: value)

        let dateComponents = NSDateComponents()
        dateComponents.year = value

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

    func testDateComponents() {
        let dateComponents = NSDateComponents()
        dateComponents.second = 7
        dateComponents.minute = 12
        dateComponents.hour = 6
        dateComponents.day = 2
        dateComponents.month = 5
        dateComponents.year = 1

        let expiration = Expiration(dateComponents: dateComponents)

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

}

class KGNAPITestRequest: XCTestCase {

    override func setUp() {
        super.setUp()

        API.sharedConnection().request = TestRequest()
        API.sharedConnection().clearCache()
    }

    // MARK: - PUT

    func testPutUser() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().put(NSURL(string: "user")!) { result, error in
            XCTAssertEqual(result!["name"], "Steve Wozniak")
            XCTAssertEqual(result!["company"], "Apple")
            XCTAssertEqual(result!["year_of_birth"], 1950)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testPutCar() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().put(NSURL(string: "car")!) { result, error in
            XCTAssertEqual(result!["company"], "Porsche")
            XCTAssertEqual(result!["model"], "GT3")
            XCTAssertEqual(result!["year"], 2014)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testPutHeaders() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().put(NSURL(string: "headers")!, headers: ["Authorization": "token", "type": "put"]) { result, error in
            XCTAssertEqual(result!["Authorization"], "token")
            XCTAssertEqual(result!["type"], "put")
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testPutBody() {
        let expectation = expectationWithDescription(__FUNCTION__)

        let bodyData = API.JSONData(["type": "put", "number": 1])
        API.sharedConnection().put(NSURL(string: "body")!, body: bodyData) { result, error in
            XCTAssertEqual(result!["type"], "put")
            XCTAssertEqual(result!["number"], 1)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testPutError() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().put(NSURL(string: "error")!) { result, error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error!.domain, "test.kgn.api.error.put")
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    // MARK: - POST

    func testPostUser() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().post(NSURL(string: "user")!) { result, error in
            XCTAssertEqual(result!["name"], "Bill Gates")
            XCTAssertEqual(result!["company"], "Microsoft")
            XCTAssertEqual(result!["year_of_birth"], 1955)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testPostCar() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().post(NSURL(string: "car")!) { result, error in
            XCTAssertEqual(result!["company"], "Porsche")
            XCTAssertEqual(result!["model"], "911")
            XCTAssertEqual(result!["year"], 2008)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testPostHeaders() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().post(NSURL(string: "headers")!, headers: ["Authorization": "token", "type": "post"]) { result, error in
            XCTAssertEqual(result!["Authorization"], "token")
            XCTAssertEqual(result!["type"], "post")
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testPostBody() {
        let expectation = expectationWithDescription(__FUNCTION__)

        let bodyData = API.JSONData(["type": "post", "number": 2])
        API.sharedConnection().post(NSURL(string: "body")!, body: bodyData) { result, error in
            XCTAssertEqual(result!["type"], "post")
            XCTAssertEqual(result!["number"], 2)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testPostError() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().post(NSURL(string: "error")!) { result, error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error!.domain, "test.kgn.api.error.post")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    // MARK: - GET

    func testGetUser() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().get(NSURL(string: "user")!) { result, error, location in
            XCTAssertEqual(result!["name"], "Steve Jobs")
            XCTAssertEqual(result!["company"], "Apple")
            XCTAssertEqual(result!["year_of_birth"], 1955)
            XCTAssertEqual(location, .API)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testGetUserCache() {
        let expiration = 1
        let expectation1 = expectationWithDescription(__FUNCTION__)
        API.sharedConnection().get(NSURL(string: "user")!, expiration: Expiration(seconds: expiration)) { result, error, location in
            XCTAssertNotNil(result)
            XCTAssertNil(error)
            XCTAssertEqual(location, .API)
            expectation1.fulfill()
        }

        let expectation2 = expectationWithDescription(__FUNCTION__)
        Thread.Main(delay: NSTimeInterval(expiration+1)) {
            API.sharedConnection().get(NSURL(string: "user")!) { result, error, location in
                XCTAssertNil(error)
                if location == .API {
                    XCTAssertNotNil(result)
                    expectation2.fulfill()
                } else {
                    XCTAssertNil(result)
                }
            }
        }

        waitForExpectationsWithTimeout(NSTimeInterval(expiration+2), handler: nil)
    }

    func testGetUserCacheShouldAlsoRequestIfInCacheFalse() {
        let expectation1 = expectationWithDescription(__FUNCTION__)
        API.sharedConnection().get(NSURL(string: "user")!, expiration: Expiration.Never(shouldRequestIfAlreadyInCache: false)) { result, error, location in
            XCTAssertNotNil(result)
            XCTAssertNil(error)
            XCTAssertEqual(location, .API)
            expectation1.fulfill()
        }

        let expectation2 = expectationWithDescription(__FUNCTION__)
        API.sharedConnection().get(NSURL(string: "user")!) { result, error, location in
            XCTAssertNotNil(result)
            XCTAssertNil(error)
            XCTAssertEqual(location, .API)
            expectation2.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testGetCar() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().get(NSURL(string: "car")!) { result, error, location in
            XCTAssertEqual(result!["company"], "Audi")
            XCTAssertEqual(result!["model"], "Q5")
            XCTAssertEqual(result!["year"], 2016)
            XCTAssertEqual(location, .API)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testGetHeaders() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().get(NSURL(string: "headers")!, headers: ["Authorization": "token", "type": "get"]) { result, error, location in
            XCTAssertEqual(result!["Authorization"], "token")
            XCTAssertEqual(result!["type"], "get")
            XCTAssertEqual(location, .API)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testGetBody() {
        let expectation = expectationWithDescription(__FUNCTION__)

        let bodyData = API.JSONData(["type": "get", "number": 3])
        API.sharedConnection().get(NSURL(string: "body")!, body: bodyData) { result, error, location in
            XCTAssertEqual(result!["type"], "get")
            XCTAssertEqual(result!["number"], 3)
            XCTAssertEqual(location, .API)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testGetError() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().get(NSURL(string: "error")!) { result, error, location in
            XCTAssertNotNil(error)
            XCTAssertEqual(error!.domain, "test.kgn.api.error.get")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    // MARK: - DELETE

    func testDeleteUser() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().delete(NSURL(string: "user")!) { result, error in
            XCTAssertEqual(result!.count, 0)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testDeleteCar() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().delete(NSURL(string: "car")!) { result, error in
            XCTAssertNil(result)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testDeleteHeaders() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().delete(NSURL(string: "headers")!, headers: ["Authorization": "token", "type": "delete"]) { result, error in
            XCTAssertEqual(result!["Authorization"], "token")
            XCTAssertEqual(result!["type"], "delete")
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testDeleteBody() {
        let expectation = expectationWithDescription(__FUNCTION__)

        let bodyData = API.JSONData(["type": "delete", "number": 4])
        API.sharedConnection().delete(NSURL(string: "body")!, body: bodyData) { result, error in
            XCTAssertEqual(result!["type"], "delete")
            XCTAssertEqual(result!["number"], 4)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testDeleteError() {
        let expectation = expectationWithDescription(__FUNCTION__)

        API.sharedConnection().delete(NSURL(string: "error")!) { result, error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error!.domain, "test.kgn.api.error.delete")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }

}
