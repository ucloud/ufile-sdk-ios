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
        let customDomain = DataTools.getStrData(key: KCustomDomain)

        let trimmedCustomDomain = customDomain?.trimmingCharacters(in: .whitespaces)
        let trimmedProxySuffix = proxySuffix?.trimmingCharacters(in: .whitespaces)
        let hasCustomDomain = trimmedCustomDomain != nil && !trimmedCustomDomain!.isEmpty
        let hasProxySuffix = trimmedProxySuffix != nil && !trimmedProxySuffix!.isEmpty

        guard let publicKey = bucketPublicKey, let bucket = bucketName else {
            print("bucket config does not complete, please check.. (need bucketPublicKey and bucketName)")
            return
        }
        
        if (!hasCustomDomain && !hasProxySuffix) {
            print("bucket config does not complete, please check.. (need either customDomain or proxySuffix)")
            return
        }
        

        let finalProxySuffix = hasProxySuffix ? trimmedProxySuffix : nil
        let finalCustomDomain = hasCustomDomain ? trimmedCustomDomain : nil
        
        let ufConfig = UFConfig.instanceConfig(withPrivateToken: bucketPrivateKey, publicToken: publicKey, bucket: bucket, fileOperateEncryptServer: fileOperateEncryptServer, fileAddressEncryptServer: fileAddressEncryptServer, proxySuffix: finalProxySuffix, customDomain: finalCustomDomain, isHttps:true);

        if ufConfig != nil {
            fileClient = UFFileClient.instanceFileClient(with: ufConfig)
        }
 
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        guard let client = fileClient else {
            return
        }
        
        if segue.identifier == "uploadFile" {
            let uploadVC = segue.destination as! FileUploadVC
            uploadVC.fileClient = client
        }
        else if segue.identifier == "downloadFile" {
            let downloadVC = segue.destination as! FileDownloadVC
            downloadVC.fileClient = client
        }
        else if segue.identifier == "deleteAndQueryFile" {
            let deleteQueryVC = segue.destination as! FileDeleteQueryVC
            deleteQueryVC.fileClient = client
        }
        else if segue.identifier == "multipartUploadFile" {
            let muVC = segue.destination as! FileMutipartUploadVC
            muVC.fileClient = client
        }
        else if segue.identifier == "FileList" {
            let fileListVC = segue.destination as! FileListVC
            fileListVC.fileClient = client
        }
        else if segue.identifier == "HeadFile" {
            let headFileVC = segue.destination as! FileHeadFileVC
            headFileVC.fileClient = client
        }
        
    }
 

}
