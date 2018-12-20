//
//  FileHeadFileVC.swift
//  UFileSDKDemo-swift
//
//  Created by ethan on 2018/12/12.
//  Copyright © 2018 ucloud. All rights reserved.
//

import UIKit

class FileHeadFileVC: UIViewController {

    @IBOutlet weak var fileNameTF:UITextField!
    @IBOutlet weak var resTV:UITextView!
    
    var fileClient:UFFileClient = UFFileClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func processHeadFileHandler(ufError:UFError?, ufHeadFile:UFHeadFile?) -> Void
    {
        DispatchQueue.main.async {
            if ufError == nil {
                self.resTV.text = "获取文件的HeadFile成功，服务器返回信息-->" + ufHeadFile!.description
                return
            }
            
            if ufError?.type == UFErrorType_Sys {
                let error  = ufError?.error as! NSError
                self.resTV.text = "获取文件的HeadFile失败，系统错误信息-->" + error.description
                return
            }
            
            self.resTV.text = "获取文件的HeadFile失败，服务器返回错误信息-->" + (ufError?.fileClientError.description)!
            
        }
    }
    
    @IBAction func onPressedButtonFileHeadFile(_ sender: Any)
    {
        self.hideKeyboard()
        self.resTV.text = nil
        weak var weakself:FileHeadFileVC! = self
        self.fileClient.headFile(withKeyName: self.fileNameTF.text!) { (ufError:UFError?, ufHeadFile:UFHeadFile?) in
            weakself.processHeadFileHandler(ufError: ufError, ufHeadFile: ufHeadFile)
        }
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hideKeyboard()
    }

    func hideKeyboard() -> Void
    {
        if self.fileNameTF.isFirstResponder {
            self.fileNameTF.resignFirstResponder()
        }
    }

}
