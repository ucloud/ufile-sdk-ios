//
//  DataTools.swift
//  UFileSDKDemo-swift
//
//  Created by ethan on 2018/12/11.
//  Copyright © 2018 ucloud. All rights reserved.
//

import UIKit

class DataTools: NSObject {

    class func storeStrData(strData:String , and keyName:String) ->Void{
        if (strData.isEmpty || keyName.isEmpty) {
            print("%s, store data error , reason : strData or key is nil..",#function)
            return;
        }
        KUFUserDefaults.set(strData, forKey: keyName)
        KUFUserDefaults.synchronize()
    }
    
    class func getStrData(key:String) -> String?{
        if key.isEmpty {
            print("%s, get data error , reason :  key is nil..",#function)
            return nil
        }
        return KUFUserDefaults.object(forKey: key) as? String
    }
    
}
