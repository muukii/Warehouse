//
//  WarehouseTests.swift
//  WarehouseTests
//
//  Created by Muukii on 10/5/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

import UIKit
import XCTest

class WarehouseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testDocumentDirectoryPath() {
       let path = Warehouse.documentDirectoryPath()
        println("DocumentDirectoryPath : \(path)")
        XCTAssert(path.hasSuffix("Documents"), "")
    }
    
    func testCacheDirectoryPath() {
        let path = Warehouse.cacheDirectoryPath()
        println("CacheDirectoryPath : \(path)")
        XCTAssert(path.hasSuffix("Caches"), "")
    }
    
    func testRootDirectoryPath() {
        let path = Warehouse.homeDirectoryPath()
        println(path)
    }
    
    func testTranslateAbsoluteToRelative() {
        let path = Warehouse.translateAbsoluteToRelative(Warehouse.documentDirectoryPath())
        XCTAssert((path == "/Documents"), "")
        println(path)
    }
    
    func testTranslateRelativeToAbsolute() {
        let path = Warehouse.translateRelativeToAbsolute("/Documents")
        let answer = NSHomeDirectory() + "/Documents"
        XCTAssert(path == answer, "")
    }
    
    func testSubDirectoryPath() {
        let warehouse = Warehouse()
        warehouse.subDirectoryPath = "/Test/Test"
        XCTAssert(warehouse.subDirectoryPath == "/Test/Test", "")
        
        warehouse.subDirectoryPath = "Test/Test"
        
        XCTAssert(warehouse.subDirectoryPath == "/Test/Test", "")
        
        warehouse.subDirectoryPath = "Test/Test/"
        XCTAssert(warehouse.subDirectoryPath == "/Test/Test", "")
        
        warehouse.subDirectoryPath = "/Test/Test/"
        XCTAssert(warehouse.subDirectoryPath == "/Test/Test", "")
        
    }
}
