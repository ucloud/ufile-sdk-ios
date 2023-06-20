//
//  FileManagerVC.swift
//  UFileSDKDemo-swift
//
//  Created by ethan on 2018/12/11.
//  Copyright © 2018 ucloud. All rights reserved.
//

import UIKit

class FileManagerVC: UIViewController {

    var fileClient:UFFileClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bucketPublicKey = DataTools.getStrData(key: KBucketPublicKey)
        let bucketPrivateKey = DataTools.getStrData(key: KBucketPrivateKey)
        let bucketName = DataTools.getStrData(key: KBucketName)
        let proxySuffix = DataTools.getStrData(key: KProfixSuffix)
        let fileOperateEncryptServer = DataTools.getStrData(key: KFileOperateEncryptServer)
        let fileAddressEncryptServer = DataTools.getStrData(key: KFileAddressEncryptServer)

        if (bucketPublicKey == nil || bucketName == nil || proxySuffix == nil)  {
            print("bucket config does not complete , please check..")
            return
        }
        
        let ufConfig = UFConfig.instanceConfig(withPrivateToken: bucketPrivateKey, publicToken: bucketPublicKey!, bucket: bucketName!, fileOperateEncryptServer: fileOperateEncryptServer, fileAddressEncryptServer: fileAddressEncryptServer, proxySuffix: proxySuffix!, isHttps:true);

        fileClient = UFFileClient.instanceFileClient(with: ufConfig)

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier?.elementsEqual("uploadFile"))! {
            let uploadVC:FileUploadVC = segue.destination as! FileUploadVC
            uploadVC.fileClient = fileClient!
        }
        else if (segue.identifier?.elementsEqual("downloadFile"))!{
            let downloadVC:FileDownloadVC = segue.destination as! FileDownloadVC
            downloadVC.fileClient = fileClient!
        }
        else if (segue.identifier?.elementsEqual("deleteAndQueryFile"))!{
            let deleteQueryVC:FileDeleteQueryVC = segue.destination as! FileDeleteQueryVC
            deleteQueryVC.fileClient = fileClient!
        }
        else if (segue.identifier?.elementsEqual("multipartUploadFile"))!{
            let muVC:FileMutipartUploadVC = segue.destination as! FileMutipartUploadVC
            muVC.fileClient = fileClient!
        }
        else if (segue.identifier?.elementsEqual("FileList"))!{
            let fileListVC:FileListVC = segue.destination as! FileListVC
            fileListVC.fileClient = fileClient!
        }
        else if (segue.identifier?.elementsEqual("HeadFile"))!{
            let headFileVC:FileHeadFileVC = segue.destination as! FileHeadFileVC
            headFileVC.fileClient = fileClient!
        }
        
    }
 

}
