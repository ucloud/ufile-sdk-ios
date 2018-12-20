//
//  QRCodeVC.swift
//  UFileSDKDemo-swift
//
//  Created by ethan on 2018/12/13.
//  Copyright © 2018 ucloud. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeVC: UIViewController,AVCaptureMetadataOutputObjectsDelegate{

    @IBOutlet weak var scanView:UIView!
    
    var m_device:AVCaptureDevice!
    var m_session:AVCaptureSession!
    var metadata_output:AVCaptureMetadataOutput!
    var m_previewLayer:AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        m_device = AVCaptureDevice.default(for: .video)
        do {
           let input:AVCaptureDeviceInput =  try AVCaptureDeviceInput.init(device: m_device)
           m_session = AVCaptureSession.init()
            if m_session.canAddInput(input){
                m_session.addInput(input)
            }
            
            metadata_output = AVCaptureMetadataOutput.init()
            if m_session.canAddOutput(metadata_output) {
                m_session .addOutput(metadata_output)
            }
            
            let serialQueue  = DispatchQueue(label: "videoQueue")
            metadata_output.setMetadataObjectsDelegate(self, queue: serialQueue)
            
            metadata_output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            m_previewLayer = AVCaptureVideoPreviewLayer.init(session: m_session)
            m_previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            m_previewLayer.frame = self.scanView.layer.bounds
            self.scanView.layer.insertSublayer(m_previewLayer, at: 0)
            
        } catch let error as NSError  {
            print(error.description)
        }
        
        self.startPreview()
        
    }
    
    func startPreview() -> Void {
        if self.m_session.isRunning == false {
            self.m_session.startRunning()
        }
    }
    
    func stopPreview() -> Void {
        if self.m_session.isRunning {
            self.m_session.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects == nil || metadataObjects.count <= 0 {
            return
        }
        
        let metadataObj:AVMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        var result:String
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            result = metadataObj.stringValue!
        }else {
            print("Your scaning is not QR code..")
            return
        }
        self.stopPreview()
        result = metadataObj.stringValue!
        
        DispatchQueue.main.async {
            self.dealwithScanResult(result: result)
        }
        
//        self.performSelector(onMainThread:Selector(("dealwithScanResult")), with: result, waitUntilDone: false)
    }
    
    func dealwithScanResult(result:String) -> Void {
        weak var weakself:QRCodeVC! = self
        DispatchQueue.main.async {
            weakself.stopPreview()
            let alert:UIAlertController = UIAlertController.init(title: "扫描结果", message: result, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "填充", style: .default, handler: { (UIAlertAction) in
                weakself.parseJsonStrAndStore(jsonStr: result)
                weakself.navigationController?.popViewController(animated: true)
                
            })
            alert.addAction(okAction)
            
            let cancelAction = UIAlertAction.init(title: "重扫", style: .cancel, handler: { (UIAlertActio) in
                weakself.startPreview()
            })
            
            alert.addAction(cancelAction)
            weakself.present(alert, animated: true, completion: nil)
        }
        print(result)
    }
    
    func parseJsonStrAndStore(jsonStr:String) -> Void {
        if jsonStr == nil {
           print("scan QR Code , jsonStr is nil..")
            return
        }
        
        let jsonData:Data = jsonStr.data(using: .utf8)!
        
        do {
            let dict:NSDictionary = try JSONSerialization.jsonObject(with:jsonData as Data, options: .mutableContainers) as! NSDictionary
            let keys = [KBucketPublicKey,KBucketPrivateKey,KProfixSuffix,KBucketName,KFileOperateEncryptServer,KFileAddressEncryptServer]
            for key in keys {
                DataTools.storeStrData(strData: dict.object(forKey: key) as! String, and: key)
            }
            
        } catch let error as NSError {
            print(error.description)
        }
        
    }



}
