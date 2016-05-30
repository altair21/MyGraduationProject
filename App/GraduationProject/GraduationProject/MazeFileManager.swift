//
//  MazeFileManager.swift
//  GraduationProject
//
//  Created by altair21 on 16/5/10.
//  Copyright © 2016年 altair21. All rights reserved.
//

import UIKit
import Alamofire

class MazeFileManager: NSObject {
    private static let sharedInstance = MazeFileManager()
    class var sharedManager: MazeFileManager {
        return sharedInstance
    }
    
    let mazeFileManager: NSFileManager = NSFileManager.defaultManager()
    let APIupload = serverAddress + "upload/"
    let APIgetList = serverAddress + "getList/"
    let APIdownload = serverAddress + "download/"
    let localFileDir = "/LocalFiles"
    let downloadFileDir = "/DownloadFiles"
    
    func writeToFile(text: String, upload uploadFlag: Bool, writeFileSuccess: () -> Void, writeFileFailure: () -> Void, uploadSuccess: () -> Void, uploadFailure: () -> Void) -> Bool {
        let directoryPath = getMazeFilesDirectory(isLocalFile: true)
        if !mazeFileManager.fileExistsAtPath(directoryPath) {
            try! mazeFileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        var res = true
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.stringFromDate(date)
        let fileName = dateStr + " " + NSUUID().UUIDString + ".txt"
        print(fileName)
        let filePath = NSURL(fileURLWithPath: directoryPath).URLByAppendingPathComponent(fileName)
        do {
            try text.writeToURL(filePath, atomically: true, encoding: NSUTF8StringEncoding)
            if !uploadFlag {
                dispatch_async(dispatch_get_main_queue(), { 
                    writeFileSuccess()
                })
            }
        } catch let error as NSError {
            print(error.description)
            res = false
            dispatch_async(dispatch_get_main_queue(), { 
                writeFileFailure()
            })
        }
        if res  && uploadFlag {
            uploadFile(filePath, uploadSuccess: { 
                uploadSuccess()
            }, uploadFailure: {
                uploadFailure()
            })
        }
        return res
    }
    
    func getLocalFilesList() -> Array<String> {
        let dirEnum = mazeFileManager.enumeratorAtPath(getMazeFilesDirectory(isLocalFile: true))
        var path = dirEnum?.nextObject()
        var resArr = Array<String>()
        while path != nil {
            print(path)
            resArr.append(path as! String)
            path = dirEnum?.nextObject()
        }
        return resArr
    }
    
    func getFileFullPath(fileName: String, isLocalFile localFile: Bool) -> String {
        return self.getMazeFilesDirectory(isLocalFile: localFile) + "/" + fileName
    }
    
    func getMazeFilesDirectory(isLocalFile localFile: Bool) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var documentsDirectory = paths[0]
        if localFile {
            documentsDirectory = documentsDirectory + localFileDir
        } else {
            documentsDirectory = documentsDirectory + downloadFileDir
        }
        if !mazeFileManager.fileExistsAtPath(documentsDirectory) {
            try! mazeFileManager.createDirectoryAtPath(documentsDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        return documentsDirectory
    }
    
    func uploadFile(path: NSURL, uploadSuccess: () -> Void, uploadFailure: () -> Void) {
        Alamofire.upload(.POST, APIupload,
            multipartFormData: { (multipartFormData) in
                multipartFormData.appendBodyPart(fileURL: path, name: "headImg")
            }) { (encodingResult) in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseString(completionHandler: { (response) in
                        print(response)
                        if response.description.rangeOfString("upload ok") != nil {
                            dispatch_async(dispatch_get_main_queue(), { 
                                uploadSuccess()
                            })
                        } else {
                            dispatch_async(dispatch_get_main_queue(), { 
                                uploadFailure()
                            })
                        }
                    })
                case .Failure(let encodingError):
                    dispatch_async(dispatch_get_main_queue(), { 
                        uploadFailure()
                    })
                    print(encodingError)
                }
        }
    }
    
    func getFileList(success: Result<AnyObject, NSError> -> Void, failure: NSError -> Void) {
        Alamofire.request(.GET, APIgetList, parameters: nil)
            .responseJSON { response in
                if response.result.error == nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        success(response.result)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { 
                        failure(response.result.error!)
                    })
                }
        }
    }
    
    func download(fileName: String) {
        var resPath: NSURL!
        let requestURL = APIdownload + "?filename=" + fileName
        Alamofire.download(.GET, requestURL,
            destination: { (temporaryURL, response) in
                
            let directoryURL = NSURL(fileURLWithPath: self.getMazeFilesDirectory(isLocalFile: false))
            resPath = directoryURL.URLByAppendingPathComponent(fileName)
            print(directoryURL.URLByAppendingPathComponent(fileName))
            return resPath
                
        })
    }
    
}
