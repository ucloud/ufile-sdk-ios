//
//  FileListVC.swift
//  UFileSDKDemo-swift
//
//  Created by ethan on 2018/12/12.
//  Copyright © 2018 ucloud. All rights reserved.
//

import UIKit

class FileListVC: UIViewController {

    @IBOutlet var prefixTF:UITextField!
    @IBOutlet var markerTF:UITextField!
    @IBOutlet var limitTF:UITextField!
    @IBOutlet var resTV:UITextView!
    
    var fileClient:UFFileClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func processFileListHandler(ufError:UFError?,ufPrefixFileList:UFPrefixFileList?) -> Void {
        DispatchQueue.main.async {
            if ufError == nil {
                self.resTV.text = "获取列表成功，服务器返回信息-->" + (ufPrefixFileList?.description)!
                return
            }
            
            if ufError?.type == UFErrorType_Sys {
                let error  = ufError?.error as! NSError
                self.resTV.text = "获取列表失败，系统错误信息-->" + error.description
                return
            }
            
            self.resTV.text = "获取列表失败，服务器返回错误信息-->" + (ufError?.fileClientError.description)!
        }
    }
    
    @IBAction func onpressedButtonFileList(_ sender : Any)
    {
        self.hideKeyboard()
        self.resTV.text = nil
        
        var limit  = 0
        if  (self.limitTF.text?.lengthOfBytes(using: .utf8))! > 0 {
            limit = Int(self.limitTF.text!)!
        }
        weak var weakself:FileListVC! = self
        self.fileClient.prefixFileList(withPrefix: self.prefixTF.text, marker: self.markerTF.text, limit: limit) { (ufError:UFError?, ufPrefixFileList:UFPrefixFileList?) in
            weakself.processFileListHandler(ufError: ufError, ufPrefixFileList: ufPrefixFileList)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hideKeyboard()
    }
    
    func hideKeyboard() -> Void {
        if self.prefixTF.isFirstResponder {
            self.prefixTF.resignFirstResponder()
        }
        if self.markerTF.isFirstResponder {
            self.markerTF.resignFirstResponder()
        }
        if self.limitTF.isFirstResponder {
            self.limitTF.resignFirstResponder()
        }
    }
}
