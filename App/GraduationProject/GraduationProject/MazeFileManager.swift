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
    
    func writeToFile(text: String, upload uploadFlag: Bool) -> Bool {
        let directoryPath = getMazeFilesDirectory()
        if !mazeFileManager.fileExistsAtPath(directoryPath) {
            try! mazeFileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        var res = true
        let fileName = NSUUID().UUIDString + ".txt"
        let filePath = NSURL(fileURLWithPath: directoryPath).URLByAppendingPathComponent(fileName)
        do {
            try text.writeToURL(filePath, atomically: true, encoding: NSUTF8StringEncoding)
            if !uploadFlag {
                showCenterToast("迷宫制作完成")
            }
        } catch let error as NSError {
            print(error.description)
            res = false
            showCenterToast("迷宫制作失败")
        }
        if res  && uploadFlag {
            uploadFile(filePath)
        }
        return res
    }
    
    func getLocalFilesList() -> Array<String> {
        let dirEnum = mazeFileManager.enumeratorAtPath(getMazeFilesDirectory())
        var path = dirEnum?.nextObject()
        var resArr = Array<String>()
        while path != nil {
            print(path)
            resArr.append(path as! String)
            path = dirEnum?.nextObject()
        }
        return resArr
    }
    
    func getFileFullPath(fileName: String) -> String {
        return self.getMazeFilesDirectory() + "/" + fileName
    }
    
    func getMazeFilesDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] + "/MazeFiles"
        if !mazeFileManager.fileExistsAtPath(documentsDirectory) {
            try! mazeFileManager.createDirectoryAtPath(documentsDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        return documentsDirectory
    }
    
    func uploadFile(path: NSURL) {
        Alamofire.upload(.POST, APIupload,
            multipartFormData: { (multipartFormData) in
                multipartFormData.appendBodyPart(fileURL: path, name: "headImg")
            }) { (encodingResult) in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseString(completionHandler: { (response) in
                        print(response)
                        if response.description.rangeOfString("upload ok") != nil {
                            showCenterToast("迷宫上传成功")
                        } else {
                            showCenterToast("迷宫上传失败")
                        }
                    })
                case .Failure(let encodingError):
                    showCenterToast("迷宫上传失败")
                    print(encodingError)
                }
        }
    }
    
    func getFileList(completion completion: Response<AnyObject, NSError> -> Void) {
        Alamofire.request(.GET, APIgetList, parameters: nil)
            .responseJSON { response in
                completion(response)
        }
    }
    
    func download(fileName: String) {
        var resPath: NSURL!
        let requestURL = APIdownload + "?filename=" + fileName
        Alamofire.download(.GET, requestURL,
            destination: { (temporaryURL, response) in
                
            let directoryURL = NSURL(fileURLWithPath: self.getMazeFilesDirectory())
            resPath = directoryURL.URLByAppendingPathComponent(fileName)
            print(directoryURL.URLByAppendingPathComponent(fileName))
            return resPath
                
        })
    }
    
}
