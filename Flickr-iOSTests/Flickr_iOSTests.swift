//
//  FlickrAppTests.swift
//  FlickrAppTests
//
//  Created by Bhanupriya Swami on 11/09/18.
//  Copyright © 2018 Bhanupriya. All rights reserved.
//

import XCTest
@testable import Flickr_iOS

class Flickr_iOSTests: XCTestCase {
    
    var sessionUnderTest: URLSession!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sessionUnderTest = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    override func tearDown() {
        sessionUnderTest = nil
        super.tearDown()
    }
    
    // Asynchronous test: success fast, failure slow
    func testValidCallToFlickrGetsHTTPStatusCode200() {
        
        let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&format=json&nojsoncallback=1&safe_search=1&text=kittens" + "&page=\(1)" + "&per_page=\(100)")
        
        let promise = expectation(description: "Status code: 200")
        
        let dataTask = sessionUnderTest.dataTask(with: url!) { data, response, error in
            
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    // 2
                    promise.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
        dataTask.resume()
        // 3
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func testFlickrData() {
        
        guard let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&format=json&nojsoncallback=1&safe_search=1&text=kittens" + "&page=\(1)" + "&per_page=\(100)") else { return }
        let promise = expectation(description: "Simple Request")
        var statusCode: Int?
        var responseError: Error?
        
        sessionUnderTest.dataTask(with: url) { (data, response, error) in
            
            XCTAssertNotNil(data, "No data was downloaded.") // Make sure we downloaded some data.
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            guard let data = data else { return }
            do {
                let responseJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                
                if let photos = responseJSON["photos"] as? [String: Any] {
                    if let arr = photos["photo"] as? [[String: Any]] {
                        XCTAssertTrue( arr.count > 0, "Should have at least one item" );
                        XCTAssert((arr as Any) is Array<Any>)
                        promise.fulfill()
                    }
                    else{
                        XCTFail("data not in expected format")
                    }
                }
                else{
                    XCTFail("data not in expected format")
                }
            } catch let err {
                XCTFail("Err: \(err)")
            }
            }.resume()
        waitForExpectations(timeout: 30, handler: nil)
        
        // then
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }
    
    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measure {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
    
}
