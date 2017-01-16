//
//  KGNAPITests.swift
//  KGNAPITests
//
//  Created by David Keegan on 1/24/15.
//  Copyright © 2015 David Keegan. All rights reserved.
//

import XCTest
@testable import KGNAPI

enum TestRequestError: Error {
    case put
    case post
    case get
    case delete
}

class TestRequest: APIRequest {

    func call(url: URL, method: APIMethodType, headers: [String: Any]? = nil, body: Data? = nil, callback: @escaping ((_ result: Any?, _ error: Error?) -> Void)) {
        DispatchQueue.global().asyncAfter(deadline: .now()+Double(arc4random_uniform(50))*0.01) {
            
            if method == .put {
                if url.absoluteString == "user" {
                    callback(["name": "Steve Wozniak", "company": "Apple", "year_of_birth": 1950], nil)
                }
                if url.absoluteString == "car" {
                    callback(["company": "Porsche", "model": "GT3", "year": 2014], nil)
                }
                if url.absoluteString == "body" {
                    callback(try? JSONSerialization.jsonObject(with: body!, options: []), nil)
                }
                if url.absoluteString == "headers" {
                    callback(headers, nil)
                }
                if url.absoluteString == "error" {
                    callback(nil, TestRequestError.put)
                }
            }

            if method == .post {
                if url.absoluteString == "user" {
                    callback(["name": "Bill Gates", "company": "Microsoft", "year_of_birth": 1955], nil)
                }
                if url.absoluteString == "car" {
                    callback(["company": "Porsche", "model": "911", "year": 2008], nil)
                }
                if url.absoluteString == "body" {
                    callback(try? JSONSerialization.jsonObject(with: body!, options: []), nil)
                }
                if url.absoluteString == "headers" {
                    callback(headers, nil)
                }
                if url.absoluteString == "error" {
                    callback(nil, TestRequestError.post)
                }
            }

            if method == .get {
                if url.absoluteString == "user" {
                    callback(["name": "Steve Jobs", "company": "Apple", "year_of_birth": 1955], nil)
                }
                if url.absoluteString == "car" {
                    callback(["company": "Audi", "model": "Q5", "year": 2016], nil)
                }
                if url.absoluteString == "body" {
                    callback(try? JSONSerialization.jsonObject(with: body!, options: []), nil)
                }
                if url.absoluteString == "headers" {
                    callback(headers, nil)
                }
                if url.absoluteString == "error" {
                    callback(nil, TestRequestError.get)
                }
            }

            if method == .delete {
                if url.absoluteString == "user" {
                    callback([], nil)
                }
                if url.absoluteString == "car" {
                    callback(nil, nil)
                }
                if url.absoluteString == "body" {
                    callback(try? JSONSerialization.jsonObject(with: body!, options: []), nil)
                }
                if url.absoluteString == "headers" {
                    callback(headers, nil)
                }
                if url.absoluteString == "error" {
                    callback(nil, TestRequestError.delete)
                }
            }

        }
    }

}

class KGNAPIEarthQuackRequest: XCTestCase {

    override func setUp() {
        super.setUp()

        API.shared.request = URLSessionAPIRequest()
        API.shared.clearCache()
    }

    func testGetCount() {
        let expectation = self.expectation(description: #function)

        API.shared.get(url: URL(string: "http://earthquake.usgs.gov/fdsnws/event/1/count?format=geojson")!) { result, error, location in
            let json = try! JSONSerialization.jsonObject(with: result as! Data, options: []) as! [String: Any]
            XCTAssertNotNil(json["count"])
            XCTAssertNotNil(json["maxAllowed"])
            XCTAssertEqual(location, .api)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
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

        var dateComponents = DateComponents()
        dateComponents.second = value

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

    func testMinutes() {
        let value = 32
        let expiration = Expiration(minutes: value)

        var dateComponents = DateComponents()
        dateComponents.minute = value

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

    func testHours() {
        let value = 6
        let expiration = Expiration(hours: value)

        var dateComponents = DateComponents()
        dateComponents.hour = value

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

    func testDays() {
        let value = 4
        let expiration = Expiration(days: value)

        var dateComponents = DateComponents()
        dateComponents.day = value

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

    func testWeeks() {
        let value = 6
        let expiration = Expiration(weeks: value)

        var dateComponents = DateComponents()
        dateComponents.day = value*7

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

    func testMonths() {
        let value = 2
        let expiration = Expiration(months: value)

        var dateComponents = DateComponents()
        dateComponents.month = value

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

    func testYears() {
        let value = 7
        let expiration = Expiration(years: value)

        var dateComponents = DateComponents()
        dateComponents.year = value

        XCTAssertEqual(dateComponents, expiration.dateComponents)
    }

    func testDateComponents() {
        var dateComponents = DateComponents()
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

        API.shared.request = TestRequest()
        API.shared.clearCache()
    }

    // MARK: - PUT

    func testPutUser() {
        let expectation = self.expectation(description: #function)

        API.shared.put(url: URL(string: "user")!) { result, error in
            let data = result as? [String: Any]
            XCTAssertEqual(data?["name"] as? String, "Steve Wozniak")
            XCTAssertEqual(data?["company"] as? String, "Apple")
            XCTAssertEqual(data?["year_of_birth"] as? Int, 1950)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPutCar() {
        let expectation = self.expectation(description: #function)

        API.shared.put(url: URL(string: "car")!) { result, error in
            let data = result as? [String: Any]
            XCTAssertEqual(data?["company"] as? String, "Porsche")
            XCTAssertEqual(data?["model"] as? String, "GT3")
            XCTAssertEqual(data?["year"] as? Int, 2014)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPutHeaders() {
        let expectation = self.expectation(description: #function)

        API.shared.put(url: URL(string: "headers")!, headers: ["Authorization": "token", "type": "put"]) { result, error in
            let data = result as? [String: Any]
            XCTAssertEqual(data?["Authorization"] as? String, "token")
            XCTAssertEqual(data?["type"] as? String, "put")
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPutBody() {
        let expectation = self.expectation(description: #function)

        let bodyData = API.JSONData(["type": "put", "number": 1])
        API.shared.put(url: URL(string: "body")!, body: bodyData) { result, error in
            let data = result as? [String: Any]
            XCTAssertEqual(data?["type"] as? String, "put")
            XCTAssertEqual(data?["number"] as? Int, 1)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPutError() {
        let expectation = self.expectation(description: #function)

        API.shared.put(url: URL(string: "error")!) { result, error in
            XCTAssertEqual(error?.localizedDescription, TestRequestError.put.localizedDescription)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - POST

    func testPostUser() {
        let expectation = self.expectation(description: #function)

        API.shared.post(url: URL(string: "user")!) { result, error in
            let data = result as? [String: Any]
            XCTAssertEqual(data?["name"] as? String, "Bill Gates")
            XCTAssertEqual(data?["company"] as? String, "Microsoft")
            XCTAssertEqual(data?["year_of_birth"] as? Int, 1955)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPostCar() {
        let expectation = self.expectation(description: #function)

        API.shared.post(url: URL(string: "car")!) { result, error in
            let data = result as? [String: Any]
            XCTAssertEqual(data?["company"] as? String, "Porsche")
            XCTAssertEqual(data?["model"] as? String, "911")
            XCTAssertEqual(data?["year"] as? Int, 2008)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPostHeaders() {
        let expectation = self.expectation(description: #function)

        API.shared.post(url: URL(string: "headers")!, headers: ["Authorization": "token", "type": "post"]) { result, error in
            let data = result as? [String: Any]
            XCTAssertEqual(data?["Authorization"] as? String, "token")
            XCTAssertEqual(data?["type"] as? String, "post")
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPostBody() {
        let expectation = self.expectation(description: #function)

        let bodyData = API.JSONData(["type": "post", "number": 2])
        API.shared.post(url: URL(string: "body")!, body: bodyData) { result, error in
            let data = result as? [String: Any]
            XCTAssertEqual(data?["type"] as? String, "post")
            XCTAssertEqual(data?["number"] as? Int, 2)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testPostError() {
        let expectation = self.expectation(description: #function)

        API.shared.post(url: URL(string: "error")!) { result, error in
            XCTAssertEqual(error?.localizedDescription, TestRequestError.post.localizedDescription)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - GET

    func testGetUser() {
        let expectation = self.expectation(description: #function)

        API.shared.get(url: URL(string: "user")!) { result, error, location in
            let data = result as? [String: Any]
            XCTAssertEqual(data?["name"] as? String, "Steve Jobs")
            XCTAssertEqual(data?["company"] as? String, "Apple")
            XCTAssertEqual(data?["year_of_birth"] as? Int, 1955)
            XCTAssertEqual(location, .api)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testGetUserCache() {
        let expiration = 1
        let expectation1 = expectation(description: #function)
        API.shared.get(url: URL(string: "user")!, expiration: Expiration(seconds: expiration)) { result, error, location in
            XCTAssertNotNil(result)
            XCTAssertNil(error)
            if location == .api {
                expectation1.fulfill()
            }
        }

        let expectation2 = expectation(description: #function)
        DispatchQueue.main.asyncAfter(deadline: .now()+Double(expiration+1)) {
            API.shared.get(url: URL(string: "user")!) { result, error, location in
                XCTAssertNil(error)
                if location == .api {
                    XCTAssertNotNil(result)
                    expectation2.fulfill()
                } else {
                    XCTAssertNil(result)
                }
            }
        }

        waitForExpectations(timeout: TimeInterval(expiration+2), handler: nil)
    }

    func testGetUserCacheShouldAlsoRequestIfInCacheFalse() {
        let expectation1 = expectation(description: #function)
        API.shared.get(url: URL(string: "user")!, expiration: Expiration.Never(shouldRequestIfAlreadyInCache: false)) { result, error, location in
            XCTAssertNotNil(result)
            XCTAssertNil(error)
            XCTAssertEqual(location, .api)
            expectation1.fulfill()
        }

        let expectation2 = expectation(description: #function)
        API.shared.get(url: URL(string: "user")!) { result, error, location in
            XCTAssertNotNil(result)
            XCTAssertNil(error)
            XCTAssertEqual(location, .api)
            expectation2.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testGetCar() {
        let expectation = self.expectation(description: #function)

        API.shared.get(url: URL(string: "car")!) { result, error, location in
            let data = result as? [String: Any]
            XCTAssertEqual(data?["company"] as? String, "Audi")
            XCTAssertEqual(data?["model"] as? String, "Q5")
            XCTAssertEqual(data?["year"] as? Int, 2016)
            XCTAssertEqual(location, .api)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testGetHeaders() {
        let expectation = self.expectation(description: #function)

        API.shared.get(url: URL(string: "headers")!, headers: ["Authorization": "token", "type": "get"]) { result, error, location in
            let data = result as? [String: Any]
            XCTAssertEqual(data?["Authorization"] as? String, "token")
            XCTAssertEqual(data?["type"] as? String, "get")
            XCTAssertEqual(location, .api)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testGetBody() {
        let expectation = self.expectation(description: #function)

        let bodyData = API.JSONData(["type": "get", "number": 3])
        API.shared.get(url: URL(string: "body")!, body: bodyData) { result, error, location in
            let data = result as? [String: Any]
            XCTAssertEqual(data?["type"] as? String, "get")
            XCTAssertEqual(data?["number"] as? Int, 3)
            XCTAssertEqual(location, .api)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testGetError() {
        let expectation = self.expectation(description: #function)

        API.shared.get(url: URL(string: "error")!) { result, error, location in
            XCTAssertEqual(error?.localizedDescription, TestRequestError.get.localizedDescription)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - DELETE

    func testDeleteUser() {
        let expectation = self.expectation(description: #function)

        API.shared.delete(url: URL(string: "user")!) { result, error in
            let data = result as? [String: Any]
            XCTAssertNil(data)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testDeleteCar() {
        let expectation = self.expectation(description: #function)

        API.shared.delete(url: URL(string: "car")!) { result, error in
            XCTAssertNil(result)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testDeleteHeaders() {
        let expectation = self.expectation(description: #function)

        API.shared.delete(url: URL(string: "headers")!, headers: ["Authorization": "token", "type": "delete"]) { result, error in
            let data = result as? [String: Any]
            XCTAssertEqual(data?["Authorization"] as? String, "token")
            XCTAssertEqual(data?["type"] as? String, "delete")
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testDeleteBody() {
        let expectation = self.expectation(description: #function)

        let bodyData = API.JSONData(["type": "delete", "number": 4])
        API.shared.delete(url: URL(string: "body")!, body: bodyData) { result, error in
            let data = result as? [String: Any]
            XCTAssertEqual(data?["type"] as? String, "delete")
            XCTAssertEqual(data?["number"] as? Int, 4)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testDeleteError() {
        let expectation = self.expectation(description: #function)

        API.shared.delete(url: URL(string: "error")!) { result, error in
            XCTAssertEqual(error?.localizedDescription, TestRequestError.delete.localizedDescription)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

}
