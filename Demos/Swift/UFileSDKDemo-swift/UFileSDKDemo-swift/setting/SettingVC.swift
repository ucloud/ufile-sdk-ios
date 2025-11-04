//
//  SettingVC.swift
//  UFileSDKDemo-swift
//
//  Created by ethan on 2018/12/11.
//  Copyright © 2018 ucloud. All rights reserved.
//

import UIKit


class SettingVC: UIViewController {
    @IBOutlet weak var bucketPublicKeyTV: UITextView!
    @IBOutlet weak var bucketPrivateKeyTV: UITextView!
    @IBOutlet weak var proxySuffixTV: UITextView!
    @IBOutlet weak var bucketTF:UITextField!
    @IBOutlet weak var versionLabel:UILabel!
    @IBOutlet weak var fOptEncryptServerTV:UITextView!
    @IBOutlet weak var fAddressEncryptServerTV:UITextView!
    @IBOutlet weak var customDomainTV:UITextView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let infoDict = Bundle.main.infoDictionary
        
        let appVersion = infoDict?["CFBundleShortVersionString"]
        let appBuild   = infoDict?["CFBundleVersion"]
        versionLabel.text = String(format:"SDK v%@ ; APP v%@.%@",arguments:[UFSDKManager.shareInstance().version(),appVersion as! CVarArg,appBuild as! CVarArg])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showData()
    }
    
    @IBAction func onpressedButtonApplay(_ sender: Any)
    {
        self.hideKeyBoard()
        self.storeData()
        self.restartApp()
    }
    
    func restartApp() -> Void {
        let alertController = UIAlertController.init(title: "Warning", message: "The setting is successful and takes effect after restarting", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (ACTION) in
            exit(0)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.hideKeyBoard();
    }
    
    func showData() -> Void
    {
        bucketPublicKeyTV.text = DataTools.getStrData(key: KBucketPublicKey)
        bucketPrivateKeyTV.text = DataTools.getStrData(key: KBucketPrivateKey)
        proxySuffixTV.text = DataTools.getStrData(key: KProfixSuffix)
        bucketTF.text = DataTools.getStrData(key: KBucketName)
        fOptEncryptServerTV.text = DataTools.getStrData(key: KFileOperateEncryptServer)
        fAddressEncryptServerTV.text = DataTools.getStrData(key: KFileAddressEncryptServer)
        customDomainTV.text = DataTools.getStrData(key: KCustomDomain)
    }
    
    func storeData() -> Void
    {
        let inputDict:[String:Any] = [KBucketPublicKey:self.bucketPublicKeyTV,KBucketPrivateKey:self.bucketPrivateKeyTV,
                                      KProfixSuffix:self.proxySuffixTV,KBucketName:self.bucketTF,
                                      KFileOperateEncryptServer:self.fOptEncryptServerTV,KFileAddressEncryptServer:self.fAddressEncryptServerTV,
                                      KCustomDomain:self.customDomainTV]
        let keys = inputDict.keys;
        for key in keys {
            if inputDict[key] is UITextField {
                let tf:UITextField! = inputDict[key] as? UITextField
                if tf.text!.isEmpty {
                    DataTools.storeStrData(strData: " ", and: key)
                }else{
                    DataTools.storeStrData(strData: tf.text!, and: key);
                }
            }
            
            if inputDict[key] is UITextView {
                let tf:UITextView! = inputDict[key] as? UITextView
                if tf.text!.isEmpty {
                    DataTools.storeStrData(strData: " ", and: key)
                }else{
                    DataTools.storeStrData(strData: tf.text!, and: key);
                }
            }
        }
        
        
//        if !self.bucketPublicKeyTV.text.isEmpty {
//            DataTools.storeStrData(strData: self.bucketPublicKeyTV.text, and: KBucketPublicKey)
//        }
//        if !self.bucketPrivateKeyTV.text.isEmpty {
//            DataTools.storeStrData(strData: self.bucketPrivateKeyTV.text, and: KBucketPrivateKey)
//        }
//        if !self.proxySuffixTV.text.isEmpty {
//            DataTools.storeStrData(strData: self.proxySuffixTV.text, and: KProfixSuffix)
//        }
//
//        var isNull = false
//        isNull = (bucketTF.text?.isEmpty)!
//        if !isNull {
//            DataTools.storeStrData(strData: bucketTF.text ?? "", and: KBucketName)
//        }
        
    }
    

    func hideKeyBoard() -> Void {
        let tvs:[UITextView] = [self.bucketPublicKeyTV,self.bucketPrivateKeyTV,self.proxySuffixTV,self.fOptEncryptServerTV,self.fAddressEncryptServerTV,self.customDomainTV];
        for tv in tvs.enumerated() {
            if tv.element.isFirstResponder{
                tv.element.resignFirstResponder();
            }
        }
        
        if self.bucketTF.isFirstResponder {
            self.bucketTF.resignFirstResponder();
        }
    }

}
