// Warehouse.swift
//
// Copyright (c) 2015 muukii
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public class Warehouse: NSObject {
    func WHLog(object: AnyObject?) {
        #if WAREHOUSE_DEBUG
            print(object)
        #endif
    }
    
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
    
    public var saveLogs = [[String:String]]()
    
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
    
    public convenience init(directoryType: DirectoryType, subDirectoryPath: String?) {
        self.init()
        self.directoryType = directoryType
		self.subDirectoryPath = subDirectoryPath
        self.createDirectoryIfNeeded()
    }
    
   public func createDirectoryIfNeeded() -> Bool{
        let directoryPath = self.saveDirectoryAbsolutePath()
        do {
            try self.fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
            WHLog("Create Directory Success \(directoryPath)")
            return true
        } catch _ {
            WHLog("Create Directory Failed \(directoryPath)")
            return false
        }
    }

    
    private func saveAndWait(savePath savePath: String, contents: NSData) -> Bool {
        
        let createLog: (Bool -> (Void)) = { (success: Bool) -> Void in
            // log
            let stateString = success ? "Success" : "Failed"
            let log = [
                "State" : stateString,
                "FilePath" : savePath
            ]
            self.saveLogs.append(log)
        }

        if self.createDirectoryIfNeeded() {
            if self.fileManager.createFileAtPath(savePath, contents: contents, attributes: nil) {
                WHLog("File create success \(savePath)")
                createLog(true)
                return true
            } else {
                WHLog("File create failure \(savePath)")
                createLog(false)
                return false
            }
        } else {
            WHLog("Failed create directory")
            createLog(false)
            return false
        }
    }
    
    
    public func saveFile(fileName fileName: String, contents: NSData,
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
    
    public func saveFileAndWait(fileName fileName: String?, contents: NSData?) -> String? {
        if let fileName = fileName {
            let path = self.saveDirectoryAbsolutePath() + fileName
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
    
    public func removeSubdirectory() throws {
        try self.fileManager.removeItemAtPath(self.saveDirectoryAbsolutePath())
    }
    
    public func saveDirectoryAbsolutePath() -> String {
        let subDirectoryPath = self.subDirectoryPath ?? ""
        let absolutePath = self.directoryType.Path() + "\(subDirectoryPath)/"
        return absolutePath
    }
    
    public func purgeSaveLogs() {
        self.saveLogs = [[String : String]]()
    }
    
    // MARK: - Class Methos
    
    public class func openFile(relativePath relativePath: String?) -> NSData? {
        
        if let path = relativePath {
            if let absolutePath = Warehouse.translateRelativeToAbsolute(path) {
                let data = NSData(contentsOfFile: absolutePath)
                return data
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    /**
    File Exists (directory is false)
    
    - parameter relativePath:
    
    - returns:
    */
    public class func fileExistsAtPath(relativePath relativePath: String?) -> Bool {
        if let path = relativePath {
            if let absolutePath = Warehouse.translateRelativeToAbsolute(path) {
                var isDirectory: ObjCBool = false
                var results: Bool = false
                results = NSFileManager.defaultManager().fileExistsAtPath(absolutePath, isDirectory: &isDirectory)
                
                if results && !isDirectory {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    public class func warehouseForDocument(subDirectoryPath: String?) -> Warehouse {
        let warehouse = Warehouse(directoryType: DirectoryType.Document, subDirectoryPath: subDirectoryPath)
        return warehouse
    }
    
    public class func warehouseForCache(subDirectoryPath: String?) -> Warehouse {
        let warehouse = Warehouse(directoryType: DirectoryType.Cache, subDirectoryPath: subDirectoryPath)
        return warehouse
    }
    
    public class func warehouseForTemporary(subDirectoryPath: String?) -> Warehouse {
        let warehouse = Warehouse(directoryType: DirectoryType.Temporary, subDirectoryPath: subDirectoryPath)
        return warehouse
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
        return paths.first!
    }
    
    public class func cacheDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        return paths.first!
    }
    
    public class func translateAbsoluteToRelative(path :String?) -> String? {
        if let path = path {
            if path.hasPrefix(self.homeDirectoryPath()) {
                return path.stringByReplacingOccurrencesOfString(self.homeDirectoryPath(), withString: "", options: [], range: nil)
            } else {
                return path
            }
        } else {
            return nil
        }
    }
    
    public class func translateRelativeToAbsolute(path :String?) -> String? {
        if let path = path {
            if path.hasPrefix(self.homeDirectoryPath()) {
                return path
            } else {
                return (self.homeDirectoryPath() as NSString).stringByAppendingPathComponent(path) as String
            }
        } else {
            return nil
        }
    }
}
