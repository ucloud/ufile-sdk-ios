//
//  FileMutipartUploadVC.swift
//  UFileSDKDemo-swift
//
//  Created by ethan on 2018/12/12.
//  Copyright © 2018 ucloud. All rights reserved.
//

import UIKit

class FileMutipartUploadVC: UIViewController,UITableViewDataSource {

    

    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var prepareBtn:UIButton!
    @IBOutlet weak var cancelBtn:UIButton!
    @IBOutlet weak var finishBtn:UIButton!
    
    var fileClient:UFFileClient!
    var dataManager:UFDataManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.cancelBtn.isEnabled = false
        self.finishBtn.isEnabled = false 
        
    }
    
    @IBAction func onpressedButtonPrepareUpload(_ sender: Any)
    {
        self.prepareBtn.isEnabled = false
        self.cancelBtn.isEnabled = true
        self.finishBtn.isEnabled = true
        
        let keyName = "testVideo.MOV"
        let filePath =  Bundle.main.path(forResource: "testVideo", ofType: "MOV")
        
        weak var weakself:FileMutipartUploadVC! = self
        self.fileClient.prepareMultipartUpload(withKeyName: keyName, mimeType: "video/quicktime") { (ufError:UFError?, ufMultiPartInfo:UFMultiPartInfo?) in
            
            if ufError == nil {
                DispatchQueue.main.async {
                    weakself.dataManager = UFDataManager.init(multiPartInfo: ufMultiPartInfo!, filePath: filePath!)
                    weakself.tableView.reloadData()
                }
                
                DispatchQueue.main.async {
                    weakself.showAlertWithTitle(title:"Prepare Multipart Upload", msg:(ufMultiPartInfo?.description)!)
                }
                return
            }
            
            var erMsg = ""
            if ufError!.type == UFErrorType_Server {
                erMsg  = ufError!.fileClientError.errMsg
            }else {
                let error  = ufError?.error as! NSError
                erMsg = error.description
            }
    
            DispatchQueue.main.async {
             weakself.showAlertWithTitle(title:"Prepare Multipart Upload", msg:erMsg)
            }
            
        }
    }
    
    @IBAction func onpressedButtonCancelUpload(_ sender: Any)
    {
        self.cancelBtn.isEnabled = false
        self.finishBtn.isEnabled = false
        self.prepareBtn.isEnabled = true
        
        weak var weakself:FileMutipartUploadVC! = self
        if self.dataManager == nil{
            return;
        }
        self.fileClient.multipartUploadAbort(withKeyName: self.dataManager!.multiPartInfo!.key, mimeType: "video/quicktime", uploadId: self.dataManager!.multiPartInfo!.uploadId) { (ufError:UFError?, ufUploadResponse:UFUploadResponse?) in
            if ufError == nil && ufUploadResponse?.statusCode == 200{
                DispatchQueue.main.async {
                    weakself.dataManager!.resetTableData()
                    weakself.tableView.reloadData()
                    weakself.showAlertWithTitle(title: "Cancel upload", msg: "succeed cancel upload!")
                }
                return
            }
            
            var erMsg = ""
            if ufError!.type == UFErrorType_Server {
                erMsg  = ufError!.fileClientError.errMsg
            }else {
                let error  = ufError?.error as! NSError
                erMsg = error.description
            }
            
            DispatchQueue.main.async {
                weakself.showAlertWithTitle(title:"Cancel upload", msg:erMsg)
            }
        }
    }
    
    @IBAction func onpressedButtonFinishUpload(_ sender:Any)
    {
        self.cancelBtn.isEnabled = false
        self.finishBtn.isEnabled = false
        self.prepareBtn.isEnabled = true
        
        weak var weakself:FileMutipartUploadVC! = self
        if self.dataManager == nil{
            return;
        }
        self.fileClient.multipartUploadFinish(withKeyName: self.dataManager!.multiPartInfo!.key, mimeType: "video/quicktime", uploadId: self.dataManager!.multiPartInfo!.uploadId, newKeyName: nil, etags: self.dataManager!.etags.allValues) { (ufError:UFError?, finishUploadInfo:UFFinishMultipartUploadResponse?) in
            if ufError == nil {
                weakself.dataManager!.resetTableData()
                weakself.tableView.reloadData()
                weakself.showAlertWithTitle(title: "Finish Upload", msg: (finishUploadInfo?.description)!)
                return
            }
            
            var erMsg = ""
            if ufError!.type == UFErrorType_Server {
                erMsg  = ufError!.fileClientError.errMsg
            }else {
                let error  = ufError?.error as! NSError
                erMsg = error.description
            }
            
            DispatchQueue.main.async {
                weakself.showAlertWithTitle(title:"Finish Upload Error", msg:erMsg)
            }
        }
    }
    
    // MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataManager == nil {
            return 0
        }
        if self.dataManager!.allParts != 0 {
            return Int(self.dataManager!.allParts)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UFMultiPartCell = tableView.dequeueReusableCell(withIdentifier: "multipartcell", for: indexPath) as! UFMultiPartCell
        cell.setDataManager(dataManager: self.dataManager!, ufFileClient: self.fileClient, partNumber: indexPath.row)
        return cell
    }
    
    func showAlertWithTitle(title:String, msg:String) -> Void {
        let aletView = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        aletView.addAction(okAction)
        self.present(aletView, animated: true, completion: nil)
    }

}
