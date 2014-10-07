// Warehouse.swift
//
// Copyright (c) 2014 Muukii
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

public class Warehouse: NSObject {
    public enum DirectoryType {
        case Document
        case Cache
        case Temporary
        
        func Path() -> String {
            switch self {
            case .Document:
                return Warehouse.documentDirectoryPath()
            case .Cache:
                return Warehouse.cacheDirectoryPath()
            case .Temporary:
                return Warehouse.temporaryDirectoryPath()
            }
        }
    }
    
    public var fileManager: NSFileManager = NSFileManager.defaultManager()
    public var directoryType: DirectoryType = DirectoryType.Temporary
    
    public var subDirectoryPath: String? {
        get {
            return _subDirectoryPath
        }
        set (path) {
            // "Test" -> "/Test"
            if var path = path {
                if path.hasPrefix("/") {
                } else {
                    path = "/" + path
                }
                
                if path.hasSuffix("/") {
                    path = path.substringToIndex(path.endIndex.predecessor())
                } else {
                    
                }
                _subDirectoryPath = path
            } else {
                _subDirectoryPath = ""
            }
        }
    }
    
    private var _subDirectoryPath: String?
    
    public override init() {
        super.init()
    }
    
    public convenience init(directoryType: DirectoryType) {
        self.init()
        self.directoryType = directoryType
    }
    
    class func warehouseForDocument() -> Warehouse {
        let warehouse = Warehouse(directoryType: DirectoryType.Document)
        return warehouse
    }
    
    class func warehouseForCache() -> Warehouse {
        let warehouse = Warehouse(directoryType: DirectoryType.Cache)
        return warehouse
    }
    
    class func warehouseForTemporary() -> Warehouse {
        let warehouse = Warehouse(directoryType: DirectoryType.Temporary)
        return warehouse
    }
    
    private func saveAndWait(#savePath: String, contents: NSData) -> Bool{
        println("\(savePath)")
        let directoryPath = savePath.stringByDeletingLastPathComponent
        println(directoryPath)
        var error: NSError?
        if self.fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil, error: &error) {
            if error == nil {
                // Success create directory
//                if self.fileManager.fileExistsAtPath(savePath) {
//                    let fileHandle = NSFileHandle(forWritingAtPath: savePath)
//                    fileHandle?.seekToEndOfFile()
//                    fileHandle?.writeData(contents)
//                    fileHandle?.closeFile()
//                    println("File overwrite success")
//                } else {
//                   
//                }
                if self.fileManager.createFileAtPath(savePath, contents: contents, attributes: nil) {
                    println("File create success")
                    return true
                } else {
                    println("File create failure")
                    return false
                }
            } else {
                println(error)
                return false
            }
        } else {
            println("Failed create directory")
            return false
        }
        
    }
    
    
    public func saveFile(#fileName: String, contents: NSData,
        success :((savedRelativePath: String?) -> Void)?, faiure:((error: NSError?) -> Void)?) {
        let subDirectoryPath = self.subDirectoryPath ?? ""
        let path = self.directoryType.Path() + "\(subDirectoryPath)/" + fileName
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                let result: Bool = self.saveAndWait(savePath: path, contents: contents)
                if result {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let relativePath = Warehouse.translateAbsoluteToRelative(path)
                        success?(savedRelativePath: relativePath)
                        return
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        faiure?(error: nil)
                        return
                    })
                }
            })
    }
    
    public func saveFileAndWait(#fileName: String?, contents: NSData?) -> String? {
        if let fileName = fileName {
            let subDirectoryPath = self.subDirectoryPath ?? ""
            let path = self.directoryType.Path() + "\(subDirectoryPath)/" + fileName
    
            if let contents = contents {
                let result: Bool = self.saveAndWait(savePath: path, contents: contents)
                if result {
                    let relativePath = Warehouse.translateAbsoluteToRelative(path)
                    return relativePath
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    public class func openFile(#relativePath: String?) -> NSData? {
        if let path = relativePath {
            let absolutePath = Warehouse.translateRelativeToAbsolute(path)
            let data = NSData(contentsOfFile: absolutePath)
            return data
        } else {
            return nil
        }
    }
    
    public class func homeDirectoryPath() -> String {
        return NSHomeDirectory()
    }
    
    public class func temporaryDirectoryPath() -> String{
        var path = NSTemporaryDirectory()
        if path.hasSuffix("/") {
            path = path.substringToIndex(path.endIndex.predecessor())
        }
        return path
    }
    
    public class func documentDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        return paths.first as String
    }
    
    public class func cacheDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        return paths.first as String
    }
    
    public class func translateAbsoluteToRelative(path :String) -> String {
        if path.hasPrefix(self.homeDirectoryPath()) {
            return path.stringByReplacingOccurrencesOfString(self.homeDirectoryPath(), withString: "", options: nil, range: nil)
        } else {
            return path
        }
    }
    
    public class func translateRelativeToAbsolute(path :String) -> String{
        if path.hasPrefix(self.homeDirectoryPath()) {
            return path
        } else {
            return self.homeDirectoryPath() + path
        }
    }
}
