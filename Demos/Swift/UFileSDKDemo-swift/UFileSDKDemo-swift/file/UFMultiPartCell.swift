//
//  UFMultiPartCell.swift
//  UFileSDKDemo-swift
//
//  Created by ethan on 2018/12/13.
//  Copyright © 2018 ucloud. All rights reserved.
//

import UIKit

class UFMultiPartCell: UITableViewCell {

    @IBOutlet weak var progress:UIProgressView!
    @IBOutlet weak var btnUpload:UIButton!
    
    var partNumber:Int = 0
    var ufFileClient:UFFileClient = UFFileClient()
    var dataManager:UFDataManager? = nil
    var bUploadded:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.progress.progress = 0
        self.progress.progressTintColor = UIColor.blue
    }
    
    public func setDataManager(dataManager:UFDataManager, ufFileClient:UFFileClient, partNumber:Int) -> Void {
        self.dataManager = dataManager
        self.ufFileClient = ufFileClient
        self.partNumber = partNumber
        
        let etag = self.dataManager!.etags.object(forKey: String(partNumber))
        if etag == nil {
            self.progress.progress = 0
            self.btnUpload.isEnabled = true
            return
        }
        self.progress.progress = 1
        self.btnUpload.isEnabled = false
    }
    
    @IBAction func onpressedButtonUpload(_ sender: Any)
    {
        weak var weakself:UFMultiPartCell! = self
        self.ufFileClient.startMultipartUpload(withKeyName: (self.dataManager!.multiPartInfo?.key)!, mimeType: "video/quicktime", uploadId: self.dataManager!.multiPartInfo!.uploadId, part: self.partNumber, fileData: self.dataManager!.getDataForPart(partNumber: UInt(self.partNumber)), progress: { (progress:Progress) in
            
            DispatchQueue.main.async {
                weakself.progress.setProgress(Float(progress.fractionCompleted), animated: true)
            }
            
        }) { (ufError:UFError?, ufUploadResponse:UFUploadResponse?) in
            if ufError == nil {
                weakself.bUploadded = true
                weakself.btnUpload.isEnabled = false
                weakself.dataManager!.addEtag(etag: (ufUploadResponse?.etag)!, partNumber: Int(ufUploadResponse!.partNumber))
                return
            }
            
            DispatchQueue.main.async {
                weakself.progress.progressTintColor = UIColor.red
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
