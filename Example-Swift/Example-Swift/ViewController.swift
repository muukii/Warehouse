//
//  ViewController.swift
//  Example-Swift
//
//  Created by Muukii on 10/5/14.
//  Copyright (c) 2014 Muukii. All rights reserved.
//

import UIKit
import Warehouse

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var path = Warehouse.documentDirectoryPath()
        path = path + "/hey2/hey2.txt"
        let warehouse = Warehouse()
        warehouse.saveFileAndWait(savePath: path, contents: NSData())
        warehouse.subDirectoryPath = "/Test"
    
        warehouse.saveFile(fileName: "Muukii", contents: NSData(), success: { (savedRelativePath) -> Void in
            
        }) { (error) -> Void in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

