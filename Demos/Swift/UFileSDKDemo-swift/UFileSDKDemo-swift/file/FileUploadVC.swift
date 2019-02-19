//
//  FileUploadVC.swift
//  UFileSDKDemo-swift
//
//  Created by ethan on 2018/12/11.
//  Copyright © 2018 ucloud. All rights reserved.
//

import UIKit

class FileUploadVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    var fileClient:UFFileClient = UFFileClient()
    var imagePickerVC:UIImagePickerController!

    @IBOutlet weak var resTV: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func clearRestv() -> Void {
       
        DispatchQueue.main.async {
            self.resTV.text = ""
        }
    }
    
    func processUploadHandler(ufError:UFError?,ufUploadResponse:UFUploadResponse?) -> Void
    {
        DispatchQueue.main.async {
            if ufError == nil {
                self.resTV.text = "上传成功，服务器返回信息-->" + (ufUploadResponse?.description)!
                return
            }
            if ufError?.type == UFErrorType_Sys {
                let error  = ufError?.error as! NSError
                self.resTV.text = "上传失败，系统错误信息-->" + error.description
                return
            }
            self.resTV.text = "上传失败，服务器返回错误信息-->" + (ufError?.fileClientError.description)!

        }
    }
    
    @IBAction func onpressedButtonUpload(_ sender: Any)
    {
        self.clearRestv()
        self.processingUIBeforeDownload()
        let fileName:String = "test.jpg"
        let strPath = Bundle.main.path(forResource: "test", ofType: "jpg")
        if strPath == nil {
            return;
        }

        weak var weakself:FileUploadVC! = self
        self.fileClient.upload(withKeyName: fileName, filePath:strPath! , mimeType: "image/jpeg", progress: { (progress:Progress) in
            DispatchQueue.main.async {
                weakself.progressView.setProgress(Float(progress.fractionCompleted), animated: true)
            }
        }) { (ufError:UFError?, ufUploadResponse:UFUploadResponse?) in
            weakself.processUploadHandler(ufError: ufError, ufUploadResponse: ufUploadResponse)
        }
    }
    
    @IBAction func onpressedButtonUploadHit(_ sender: Any)
    {
        self.clearRestv()
        let fileName:String = "initscreen.jpg"
        let strPath = Bundle.main.path(forResource: "initscreen", ofType: "jpg")
        if strPath == nil {
            return
        }
        weak var weakself:FileUploadVC! = self
        self.fileClient.hitUpload(withKeyName: fileName, filePath: strPath!, mimeType: "image/jpeg") { (ufError:UFError?, ufUploadResponse:UFUploadResponse?) in
            weakself.processUploadHandler(ufError: ufError, ufUploadResponse: ufUploadResponse)
        }
    }
    
    @IBAction func onpressedButtonUploadFileWithFileMethod(_ sender: Any)
    {
        self.clearRestv()
        self.processingUIBeforeDownload()
        let fileName:String = "123.jpg"
        let strPath = Bundle.main.path(forResource: "initscreen", ofType: "jpg")
        weak var weakself:FileUploadVC! = self
        self.fileClient.upload(withKeyName: fileName, filePath: strPath!, mimeType: "image/jpeg", progress: { (progress:Progress) in
            DispatchQueue.main.async {
                weakself.progressView.setProgress(Float(progress.fractionCompleted), animated: true)
            }
        }) { (ufError:UFError?, ufUploadResponse:UFUploadResponse?) in
            weakself.processUploadHandler(ufError: ufError, ufUploadResponse: ufUploadResponse)
        }
    }
    
    @IBAction func onpressedButtonUploadNSData(_ sender: Any)
    {
        self.clearRestv()
        self.processingUIBeforeDownload()
        let key:String = "hello"
        let data:Data? = "hello world".data(using: .utf8)
        
        weak var weakself:FileUploadVC! = self
        self.fileClient.upload(withKeyName: key, fileData:data!, mimeType: nil, progress: { (progress:Progress) in
            DispatchQueue.main.async {
                weakself.progressView.setProgress(Float(progress.fractionCompleted), animated: true)
            }
        }) { (ufError:UFError?, ufUploadResponse:UFUploadResponse?) in
            weakself.processUploadHandler(ufError: ufError, ufUploadResponse: ufUploadResponse)
        }
    }
    
    @IBAction func onpressedButtonFromAlbum(_ sender: Any)
    {
        self.clearRestv()
        
        if self.imagePickerVC == nil {
            self.imagePickerVC = UIImagePickerController()
            self.imagePickerVC.delegate = self
            self.imagePickerVC.sourceType = .photoLibrary
        }
        
        self.present(self.imagePickerVC, animated: true, completion: nil)
    }
    
    // MARK:- UIImagePickerControllerDelegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        self.dismiss(animated: true, completion: nil)
        
        let image:UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let imageData:Data = image.pngData()!
        let key:String = "photo.jpg"
        weak var weakself:FileUploadVC! = self
        self.fileClient.upload(withKeyName: key, fileData: imageData, mimeType: "image/jpeg", progress: { (Progress) in
            
        }) { (ufError:UFError?, ufUploadResponse:UFUploadResponse?) in
            weakself.processUploadHandler(ufError: ufError, ufUploadResponse: ufUploadResponse)
        }
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func processingUIBeforeDownload() -> Void
    {
        self.progressView.progress = 0.0
        self.progressView.progressTintColor = UIColor.blue
    }

}
