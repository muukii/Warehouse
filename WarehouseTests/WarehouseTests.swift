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
    
    func testSavePerformance() {
        let warehouse = Warehouse()
        let data = NSData(contentsOfURL: NSURL(string: "https://fbcdn-sphotos-g-a.akamaihd.net/hphotos-ak-xap1/v/t1.0-9/10635872_760086720719014_7112759901763456857_n.jpg?oh=a17286d5c433502820cf148a7692ef2a&oe=54B9041F&__gda__=1417884355_5f6ee424afa59c50382017bf76a9f947")!)
        self.measureBlock { () -> Void in
            warehouse.saveFileAndWait(fileName: "Test", contents: data)
            return
        }
    }
    
    func testDocumentDirectoryPath() {
       let path = Warehouse.documentDirectoryPath()
        print("DocumentDirectoryPath : \(path)")
        XCTAssert(path.hasSuffix("Documents"), "")
    }
    
    func testCacheDirectoryPath() {
        let path = Warehouse.cacheDirectoryPath()
        print("CacheDirectoryPath : \(path)")
        XCTAssert(path.hasSuffix("Caches"), "")
    }
    
    func testRootDirectoryPath() {
        let path = Warehouse.homeDirectoryPath()
        print(path)
    }
    
    func testTranslateAbsoluteToRelative() {
        let path = Warehouse.translateAbsoluteToRelative(Warehouse.documentDirectoryPath())
        XCTAssert((path == "/Documents"), "")
        print(path)
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
    
    func testOpenFile() {
        let warehouse = Warehouse()
        warehouse.directoryType = .Document
        warehouse.subDirectoryPath = "/testOpenFile"
        
        let data = "Test".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        print("Save data size : \(data!.length)")
        
        let filePath = warehouse.saveFileAndWait(fileName: "TestFile.md", contents: data!)

        print("Saved file path : \(filePath)")

        XCTAssert(filePath != nil, "")

        let openData = Warehouse.openFile(relativePath: filePath!)

        print("Opened file : \(openData)")
        print("Opened file size : \(openData!.length)")
        
        XCTAssert(openData != nil, "")
        XCTAssert(openData == data, "")
    }
    
    func testOverWrite() {
    // FileCreate
        let warehouse = Warehouse()
        warehouse.directoryType = .Document
        warehouse.subDirectoryPath = "/testOpenFile"
        
        let firstData = "TestString".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        print("Save data size : \(firstData!.length)")
        
        let firstFilePath = warehouse.saveFileAndWait(fileName: "TestFile.md", contents: firstData!)
        
        print("Saved file path : \(firstFilePath)")
        
        XCTAssert(firstFilePath != nil, "")
        
        let firstOpenData = Warehouse.openFile(relativePath: firstFilePath!)
        
        print("Opened file : \(firstOpenData)")
        print("Opened file size : \(firstOpenData!.length)")
        
        XCTAssert(firstOpenData != nil, "")
        XCTAssert(firstOpenData == firstData, "")
        XCTAssert(firstOpenData?.length == firstData?.length, "")
        
        // OverWrite
        
        let secondData = "TestStringString".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        print("Save data size : \(secondData!.length)")
        
        let secondFilePath = warehouse.saveFileAndWait(fileName: "TestFile.md", contents: secondData!)
        
        print("Saved file path : \(secondFilePath)")
        
        XCTAssert(secondFilePath != nil, "")
        
        let secondOpenData = Warehouse.openFile(relativePath: secondFilePath!)
        
        print("Opened file : \(secondOpenData)")
        print("Opened file size : \(secondOpenData!.length)")
        
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
    
    func testRemoveSubdirectory() {
        let warehouse = Warehouse()
        warehouse.directoryType = .Document
        warehouse.subDirectoryPath = "/testDirectory"
        
        var paths: [String] = []
        for i in 0...100 {
            let firstData = "TestString".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            print("Save data size : \(firstData!.length)")
        
            let firstFilePath = warehouse.saveFileAndWait(fileName: "TestFile\(i).md", contents: firstData!)
            if let path = firstFilePath {
                paths.append(path)
            }
            print("Saved file path : \(firstFilePath)")
            XCTAssert(firstFilePath != nil, "")
        }
        
        try! warehouse.removeSubdirectory()
        
        paths.forEach { path in
            
            XCTAssert(Warehouse.fileExistsAtPath(relativePath: path) == false, "")
        }
    }
}
