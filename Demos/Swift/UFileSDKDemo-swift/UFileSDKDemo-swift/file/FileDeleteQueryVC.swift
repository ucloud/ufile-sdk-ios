//
//  FileDeleteQueryVC.swift
//  UFileSDKDemo-swift
//
//  Created by ethan on 2018/12/12.
//  Copyright © 2018 ucloud. All rights reserved.
//

import UIKit

class FileDeleteQueryVC: UIViewController {

    @IBOutlet weak var fileNameTF:UITextField!
    @IBOutlet weak var resTV:UITextView!
    
    var fileClient:UFFileClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.fileNameTF.text = "initscreen.jpg";
    }
    
    func processDQHandler(ufError:UFError?, ufResponse:Any?) -> Void {
        DispatchQueue.main.async {
            if ufError == nil {
                if ufResponse is UFQueryFileResponse{
                    let ufQueryFileResponse:UFQueryFileResponse =  ufResponse as! UFQueryFileResponse
                    self.resTV.text = "查询成功，服务器返回信息-->" + ufQueryFileResponse.description
                    return
                }
                if ufResponse == nil{
                    self.resTV.text = "删除成功"
                    return
                }
            }
            
            if ufError?.type == UFErrorType_Sys{
                let error  = ufError?.error as! NSError
                self.resTV.text = "删除(查询)失败，系统错误信息-->" + error.description
                return
            }
            self.resTV.text = "删除(查询)失败，服务器返回错误信息-->" + (ufError?.fileClientError.description)!
        }
    }
    
    @IBAction func onpressedButtonQuery(_ sender:Any)
    {
        self.resTV.text = nil
        self.hideKeyboaryd()
        let fileName = self.fileNameTF.text
        if (fileName?.lengthOfBytes(using: .utf8))! <= 0{
            return
        }
        
        weak var weakself:FileDeleteQueryVC! = self
        self.fileClient.query(withKeyName:fileName!) { (ufError:UFError?, ufQueryFileResponse:UFQueryFileResponse?) in
            weakself.processDQHandler(ufError: ufError, ufResponse: ufQueryFileResponse)
        }
        
    }
    
    @IBAction func onpressedButtonDelete(_ sender: Any)
    {
        self.resTV.text = nil
        self.hideKeyboaryd()
        let fileName  = self.fileNameTF.text
        if (fileName?.lengthOfBytes(using: .utf8))! <= 0{
            return
        }
        
        weak var weakself:FileDeleteQueryVC! = self
        self.fileClient.delete(withKeyName: fileName!) { (ufError:UFError?, obj:NSObject?) in
            weakself.processDQHandler(ufError: ufError, ufResponse: obj)
        }
    }
    
    func hideKeyboaryd() -> Void {
        if self.fileNameTF.isFirstResponder {
            self.fileNameTF.resignFirstResponder()
        }
    }
    

}
