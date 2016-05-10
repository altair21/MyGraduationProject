//
//  MazeFileManager.swift
//  GraduationProject
//
//  Created by altair21 on 16/5/10.
//  Copyright © 2016年 altair21. All rights reserved.
//

import UIKit

class MazeFileManager: NSObject {
    static let mazeFileManager: NSFileManager = NSFileManager.defaultManager()
    
    class func writeToFile(text: String) -> Bool {
        let directoryPath = getMazeFilesDirectory() as String
        if !mazeFileManager.fileExistsAtPath(directoryPath) {
            try! mazeFileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        var res = true
        let fileName = NSUUID().UUIDString + ".txt"
        let filePath = NSURL(fileURLWithPath: directoryPath).URLByAppendingPathComponent(fileName)
        do {
            try text.writeToURL(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print(error.description)
            res = false
        }
        return res
    }
    
    class func getMazeFilesDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] + "/MazeFiles"
        return documentsDirectory
    }
}
