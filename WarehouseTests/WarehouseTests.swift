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
        
    func testSavePerformance() {
        let warehouse = Warehouse()
        let data = NSData(contentsOfFile: NSBundle(forClass: self.dynamicType).pathForResource("sample", ofType: "png")!)!
        self.measureBlock { () -> Void in
            warehouse.saveFileAndWait(fileName: "Test", contents: data)
            return
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
    
    func testOpenFileForDocument() {
        let warehouse = Warehouse()
        warehouse.directoryType = .Document
        warehouse.subDirectoryPath = "/testOpenFile"
        self.openFile(warehouse)
    }
    
    func testOpenFileForTemporary() {
        let warehouse = Warehouse()
        warehouse.directoryType = .Temporary
        warehouse.subDirectoryPath = "/testOpenFile"
        self.openFile(warehouse)
    }
    
    func testOpenFileForCache() {
        let warehouse = Warehouse()
        warehouse.directoryType = .Cache
        warehouse.subDirectoryPath = "/testOpenFile"
        self.openFile(warehouse)
    }
    
    func openFile(warehouse: Warehouse) {
        
        let data = "Test".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        println("Save data size : \(data!.length)")
        
        let filePath = warehouse.saveFileAndWait(fileName: "TestFile.md", contents: data!)
        
        println("Saved file path : \(filePath)")
        
        XCTAssert(filePath != nil, "")
        
        let openData = Warehouse.openFile(relativePath: filePath!)
        
        println("Opened file : \(openData)")
        println("Opened file size : \(openData!.length)")
        
        XCTAssert(openData != nil, "")
        XCTAssert(openData == data, "")
    }
    
    func testOverWrite() {
    // FileCreate
        let warehouse = Warehouse()
        warehouse.directoryType = .Document
        warehouse.subDirectoryPath = "/testOpenFile"
        
        let firstData = "TestString".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        println("Save data size : \(firstData!.length)")
        
        let firstFilePath = warehouse.saveFileAndWait(fileName: "TestFile.md", contents: firstData!)
        
        println("Saved file path : \(firstFilePath)")
        
        XCTAssert(firstFilePath != nil, "")
        
        let firstOpenData = Warehouse.openFile(relativePath: firstFilePath!)
        
        println("Opened file : \(firstOpenData)")
        println("Opened file size : \(firstOpenData!.length)")
        
        XCTAssert(firstOpenData != nil, "")
        XCTAssert(firstOpenData == firstData, "")
        XCTAssert(firstOpenData?.length == firstData?.length, "")
        
        // OverWrite
        
        let secondData = "TestStringString".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        println("Save data size : \(secondData!.length)")
        
        let secondFilePath = warehouse.saveFileAndWait(fileName: "TestFile.md", contents: secondData!)
        
        println("Saved file path : \(secondFilePath)")
        
        XCTAssert(secondFilePath != nil, "")
        
        let secondOpenData = Warehouse.openFile(relativePath: secondFilePath!)
        
        println("Opened file : \(secondOpenData)")
        println("Opened file size : \(secondOpenData!.length)")
        
        XCTAssert(secondOpenData != nil, "")
        XCTAssert(secondOpenData == secondData, "")
        XCTAssert(secondOpenData?.length == secondData?.length, "")
        XCTAssert(secondFilePath == firstFilePath, "")
        XCTAssert(secondOpenData != firstData, "")
        
        /**
        *  File Exist
        */
        XCTAssert(Warehouse.fileExistsAtPath(relativePath: secondFilePath), "")
        
    }
}
