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
    fileprivate static let sharedInstance = MazeFileManager()
    class var sharedManager: MazeFileManager {
        return sharedInstance
    }
    
    let mazeFileManager: FileManager = FileManager.default
    let APIupload = serverAddress + "upload/"
    let APIgetList = serverAddress + "getList/"
    let APIdownload = serverAddress + "download/"
    let localFileDir = "/LocalFiles"
    let downloadFileDir = "/DownloadFiles"
    
    func writeToFile(_ text: String, upload uploadFlag: Bool, writeFileSuccess: @escaping () -> Void, writeFileFailure: @escaping () -> Void, uploadSuccess: @escaping () -> Void, uploadFailure: @escaping () -> Void) -> Bool {
        let directoryPath = getMazeFilesDirectory(isLocalFile: true)
        if !mazeFileManager.fileExists(atPath: directoryPath) {
            try! mazeFileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        var res = true
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        let preName = dateStr + " " + UUID().uuidString
        let fileName = preName + ".txt"
        let filePath = URL(fileURLWithPath: directoryPath).appendingPathComponent(fileName)
        do {
            try text.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
            if !uploadFlag {
                DispatchQueue.main.async(execute: { 
                    writeFileSuccess()
                })
            }
        } catch let error as NSError {
            print("error: \(error.description)")
            res = false
            DispatchQueue.main.async(execute: { 
                writeFileFailure()
            })
        }
        if res  && uploadFlag {
            uploadFile(filePath: filePath, uploadSuccess: {
                uploadSuccess()
            }, uploadFailure: {
                uploadFailure()
            })
        }
        return res
    }
    
    func getLocalFilesList(isLocalDir: Bool) -> Array<String> {
        let dirEnum = mazeFileManager.enumerator(atPath: getMazeFilesDirectory(isLocalFile: isLocalDir))
        var path = dirEnum?.nextObject()
        var resArr = Array<String>()
        while path != nil {
            resArr.append(path as! String)
            path = dirEnum?.nextObject()
        }
        return resArr
    }
    
    func getFileFullPath(_ fileName: String, isLocalFile localFile: Bool) -> String {
        return self.getMazeFilesDirectory(isLocalFile: localFile) + "/" + fileName
    }
    
    func getMazeFilesDirectory(isLocalFile localFile: Bool) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        var documentsDirectory = paths[0]
        if localFile {
            documentsDirectory = documentsDirectory + localFileDir
        } else {
            documentsDirectory = documentsDirectory + downloadFileDir
        }
        if !mazeFileManager.fileExists(atPath: documentsDirectory) {
            try! mazeFileManager.createDirectory(atPath: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        return documentsDirectory
    }
    
    func uploadFile(filePath path: URL, uploadSuccess: @escaping () -> Void, uploadFailure: @escaping () -> Void) {
        Alamofire.upload(multipartFormData: { (multipartFormDate) in
            multipartFormDate.append(path, withName: "headImg")
        }, to: APIupload) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseString(completionHandler: { (response) in
                    DispatchQueue.main.async {
                        uploadSuccess()
                    }
                })
            case .failure(_):
                DispatchQueue.main.async {
                    uploadFailure()
                }

            }
        }
    }
    
    func getFileList(_ success: @escaping (Result<Any>) -> Void, failure: @escaping (NSError) -> Void) {
        var urlRequest = URLRequest(url: URL(string: APIgetList)!)
        urlRequest.httpMethod = "GET"
        Alamofire.request(urlRequest)
            .responseJSON { (response) in
                if response.result.error == nil {
                    DispatchQueue.main.async {
                        success(response.result)
                    }
                } else {
                    DispatchQueue.main.async {
                        failure(response.result.error as! NSError)
                    }
                }

        }
    }
    
    func download(_ fileName: String, completion: @escaping ()->Void, failure: @escaping ()->Void) {
        var resPath: URL!
        let directoryURL = NSURL(fileURLWithPath: self.getMazeFilesDirectory(isLocalFile: false))
        resPath = directoryURL.appendingPathComponent(fileName)
        
        if mazeFileManager.fileExists(atPath: resPath.absoluteString) {
            completion()
        }
        
        let requestURL = APIdownload + "?filename=" + fileName
        var urlRequest = URLRequest(url: URL(string: requestURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
        urlRequest.httpMethod = "GET"
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (resPath, [.removePreviousFile, .createIntermediateDirectories])
        }
        Alamofire.download(urlRequest, to: destination).response {response in
            if response.response?.statusCode == 200 {
                completion()
            } else {
                failure()
            }
        }
    }
    
}
