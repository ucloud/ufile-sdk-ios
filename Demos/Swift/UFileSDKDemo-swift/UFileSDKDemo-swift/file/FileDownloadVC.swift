//
//  FileDownloadVC.swift
//  UFileSDKDemo-swift
//
//  Created by ethan on 2018/12/12.
//  Copyright © 2018 ucloud. All rights reserved.
//

import UIKit

class FileDownloadVC: UIViewController {
    
    @IBOutlet weak var fileNameText:UITextField!
    @IBOutlet weak var rangeBeginText:UITextField!
    @IBOutlet weak var rangeEndText:UITextField!
    @IBOutlet weak var progress:UIProgressView!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var resTV:UITextView!
    
    var fileClient:UFFileClient = UFFileClient()
    var strDownloadPath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.fileNameText.text = "initscreen.jpg"
    }
    
    func processDownloadHandler(ufError:UFError?,ufDownloadResponse:UFDownloadResponse?) -> Void {
        DispatchQueue.main.async {
            if ufError == nil {
                if ufDownloadResponse?.data != nil{
                    self.imgView.image = UIImage.init(data: (ufDownloadResponse?.data)!)
                }
                if (ufDownloadResponse?.destPath.isEmpty == false ){
                    print(self.strDownloadPath)
                    let imgData = NSData(contentsOfFile:self.strDownloadPath)
                    if imgData == nil {
                        print("read image data error..")
                        return
                    }
                    self.imgView.image = UIImage.init(data: imgData! as Data)
                }
                self.resTV.text = "下载成功，服务器返回信息-->" + (ufDownloadResponse?.description)!
                return
            }
            
            if ufError?.type == UFErrorType_Sys {
                let error  = ufError?.error as! NSError
                self.resTV.text = "下载失败，系统错误信息-->" + error.description
                return
            }
            self.resTV.text = "下载失败，服务器返回错误信息-->" + (ufError?.fileClientError.description)!
            
        }
    }
    
    @IBAction func onpressedButtonDownload(_ sender: Any)
    {
        self.resTV.text = ""
        
        self.processingUIBeforeDownload()
        let fileName = self.fileNameText.text
        let range = self.validUserInputRange()
        
        weak var weakself:FileDownloadVC! = self
        self.fileClient.download(withKeyName: fileName!, downloadRange: range, progress: { (progress:Progress) in
            DispatchQueue.main.async {
                weakself.progress.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            
        }) { (ufError:UFError?, ufDownloadResponse:UFDownloadResponse?) in
            weakself.processDownloadHandler(ufError: ufError, ufDownloadResponse: ufDownloadResponse)
        }
        
    }
    
    @IBAction func onpressedButtonDownloadToFile(_ sender: Any)
    {
        self.resTV.text = ""
        self.processingUIBeforeDownload()
        
        let fileName = self.fileNameText.text
        let range = self.validUserInputRange()
        
        let cachePaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory,
                                                             FileManager.SearchPathDomainMask.userDomainMask, true)
        let cachePath = cachePaths[0] as! String
        strDownloadPath = cachePath + "/" + fileName!
        
        weak var weakself:FileDownloadVC! = self
        self.fileClient.download(withKeyName:fileName!, destinationPath:strDownloadPath, downloadRange: range, progress: { (progress:Progress) in
            DispatchQueue.main.async {
                weakself.progress.setProgress(Float(progress.fractionCompleted), animated: true)
            }
        }) { (ufError:UFError?, ufDownloadResponse:UFDownloadResponse?) in
            weakself.processDownloadHandler(ufError: ufError, ufDownloadResponse: ufDownloadResponse)
        }
        
    }
    
    
    func hideKeyBoard() -> Void
    {
        if self.fileNameText.isFirstResponder {
            self.fileNameText.resignFirstResponder()
        }
        else if self.rangeBeginText.isFirstResponder {
            self.rangeBeginText.resignFirstResponder()
        }
        else if self.rangeEndText.isFirstResponder{
            self.rangeEndText.resignFirstResponder()
        }
    }
    
    func processingUIBeforeDownload() -> Void
    {
        self.hideKeyBoard()
        self.imgView.image = nil
        self.progress.progress = 0.0
        self.progress.progressTintColor = UIColor.blue
    }
    
    // 此处没有校验输入的必须是数字，请自行校验
    func validUserInputRange() -> UFDownloadFileRange
    {
        let rangeBegin = self.rangeBeginText.text
        let rangeEnd = self.rangeEndText.text
        var range = UFDownloadFileRange.init(begin: 0, end: 0)
        if ((rangeBegin?.lengthOfBytes(using: .utf8))! > 0 && (rangeEnd?.lengthOfBytes(using: .utf8))! > 0) {
            range = UFDownloadFileRange.init(begin: UInt(rangeBegin!)!, end: UInt(rangeEnd!)!)
        }
        return range
    }


}
