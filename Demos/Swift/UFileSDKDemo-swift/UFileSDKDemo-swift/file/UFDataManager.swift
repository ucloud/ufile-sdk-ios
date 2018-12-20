//
//  UFDataManager.swift
//  UFileSDKDemo-swift
//
//  Created by ethan on 2018/12/12.
//  Copyright © 2018 ucloud. All rights reserved.
//

import UIKit

class UFDataManager {

    var multiPartInfo:UFMultiPartInfo?
    var filePath:String?
    var etags:NSMutableDictionary
    
    var fileData:NSData? = nil
    var fileSize:UInt = 0
    var allParts:UInt = 0
    
    init(multiPartInfo:UFMultiPartInfo, filePath:String) {
        
        self.multiPartInfo = multiPartInfo
        self.filePath = filePath
        self.etags = NSMutableDictionary()
        do{
        self.fileData = try NSData(contentsOfFile: self.filePath!)
        let attr = try FileManager.default.attributesOfItem(atPath: self.filePath!)
        let dict = attr as NSDictionary
            self.fileSize = UInt(dict.fileSize())
            self.allParts = (self.fileSize + self.multiPartInfo!.blkSize - 1)/self.multiPartInfo!.blkSize
            
        }catch{
            print("Error:\(error)")
        }
    }
    
    func resetTableData() -> Void
    {
        multiPartInfo = nil
        filePath = nil
        etags = NSMutableDictionary()
        allParts = 0
    }
    
    func getDataForPart(partNumber:UInt) -> Data
    {
        if partNumber >= allParts {
            return Data()
        }
        
        let loc  = partNumber*self.multiPartInfo!.blkSize
        var length  = self.multiPartInfo!.blkSize
        let totalen = loc + length
        if totalen > self.fileSize {
            length = self.fileSize - loc
        }
        return NSMutableData.init(data: self.fileData!.subdata(with: NSRange.init(location:Int(loc), length: Int(length)))) as Data
    }
    
    func addEtag(etag:String, partNumber:Int)
    {
        self.etags .setValue(etag, forKey: String(partNumber))
    }
}
