//
//  AllInOneUITests.swift
//  AllInOneUITests
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import XCTest

class AllInOneUITests: XCTestCase {

    let app = XCUIApplication()
        
    override func setUp()
    {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    func testExample()
    {
        let table = app.tables

        let addButton = app.buttons["Add"]
        print("addButton = \(addButton)")

        let allButtons = app.descendants(matching: .button)
        print("allButtons = \(allButtons)")

        let allCellsInTable = app.tables.descendants(matching: .cell)
        print("allCellsInTable = \(allCellsInTable)")

        let allMenuItemsInMenu = app.menuBarItems.descendants(matching: .menuBarItem)
        print("allMenuItemsInMenu = \(allMenuItemsInMenu)")

        let cellQuery = table.cells.containing(.staticText, identifier: "cell")
        print("cellQuery = \(cellQuery)")

        let labelsInTable = app.tables.staticTexts
        print("labelsInTable = \(labelsInTable)")
    }

    func testHotNewsList()
    {
        //Enter hot news page
        app.tabBars.buttons.element(boundBy: 0).tap()

        //Check navigation bar title
        let navigationBarTitle = app.navigationBars.element.identifier
        XCTAssertEqual(navigationBarTitle, "Hot News", "test fail = \(navigationBarTitle.debugDescription)")

        let table = app.tables
        XCTAssertEqual(table.cells.count, 30, "test fail =  \(table.cells.debugDescription)")

        //Check title
        let firstHotNewsTitle = table.staticTexts.element(boundBy: 0).label
        print("firstHotNewsTitle = \(firstHotNewsTitle)")
        XCTAssertTrue(!firstHotNewsTitle.isEmpty)
    }

    func testRemoveAllFavoriteItems()
    {
        app.tabBars.buttons.element(boundBy: 2).tap()

        let table = app.tables
        app.navigationBars.matching(identifier: "Schedule").buttons["Edit"].tap()

//        sleep(3)

        while table.cells.count > 0 {
            let count = table.cells.count
            let cell = table.cells.element(boundBy: 0)
            cell.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Delete'")).element.tap()
            cell.children(matching: .button).matching(identifier: "Delete").element(boundBy: 0).tap()

            XCTAssertEqual(table.cells.count, count - 1)
        }

        waitForExpectations(timeout: 3, handler: nil)
    }

    func testCustomButton()
    {
        let app = XCUIApplication()

        app.buttons["red"].tap()
        app.buttons["blue"].tap()
    }
    
}
