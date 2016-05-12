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
    let APIupload = "http://127.0.0.1:8000/disk/"
    let APIgetListAPI = "http://127.0.0.1:8000/getList/"
    
    func writeToFile(text: String, upload uploadFlag: Bool) -> Bool {
        let directoryPath = getMazeFilesDirectory() as String
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
            uploadFile(filePath, filename: fileName)
        }
        return res
    }
    
    func getMazeFilesDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] + "/MazeFiles"
        return documentsDirectory
    }
    
    func uploadFile(path: NSURL, filename: String) {
        Alamofire.upload(
            .POST,
            APIupload,
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
        Alamofire.request(.GET, APIgetListAPI, parameters: nil)
            .responseJSON { response in
                completion(response)
        }
    }
    
}
