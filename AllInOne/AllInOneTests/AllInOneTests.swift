//
//  AllInOneTests.swift
//  AllInOneTests
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import XCTest
@testable import AllInOne

class AllInOneTests: XCTestCase {

    var apiService: APIService?

    let tokyoLatitude = 35.6895
    let tokyoLongidude = 139.6917


    
    override func setUp()
    {
        super.setUp()

        apiService = APIService()
        XCTAssertNotNil(apiService, "Can't create APIService instance")

    }
    
    override func tearDown()
    {
        super.tearDown()

        apiService = nil
    }
    
    func testExample()
    {
        var responseError: Error?

        let expect = XCTestExpectation(description: "callback")

        apiService?.fetchShopData(tokyoLatitude, tokyoLongidude, complete: { (success, shops, error) in

            responseError = error

            expect.fulfill()

            XCTAssertEqual(shops?.count, 100)

            for shop in shops!
            {
                XCTAssertNotNil(shop.name)
            }
        })

        wait(for: [expect], timeout: 10)

        XCTAssertNil(responseError)
    }

    //Faking Objects and Interactions
    func testFakeObjects()
    {
        //Given
        let promise = expectation(description: "Status code: 200")
        var responseData: Data?

        //When
        let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=abba")

        let dataTask = URLSession.shared.dataTask(with: url!) { (data, response, error) in

            if let error = error
            {
                print(error.localizedDescription)
            }
            else if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 200
                {
                    responseData = data
                    promise.fulfill()
                }
            }
        }

        dataTask.resume()
        waitForExpectations(timeout: 5, handler: nil)

        //Then
        XCTAssertTrue(responseData != nil)
    }

    
    func testPerformanceExample() {

        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
