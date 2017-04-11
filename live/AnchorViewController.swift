//
//  AnchorViewController.swift
//  live
//
//  Created by heyunpeng on 2016/12/26.
//  Copyright © 2016年 heyunpeng. All rights reserved.
//

import Foundation
import LFLiveKit
import SnapKit
import ReactiveCocoa

class AnchorViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setNeedsStatusBarAppearanceUpdate()
        
        urlText.addTarget(urlText, action: #selector(resignFirstResponder), for: UIControlEvents.editingDidEndOnExit)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        stopLive()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var session: LFLiveSession? = {
        let audioConfiguration = LFLiveAudioConfiguration.default()
        let videoConfigurateion = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.low3, outputImageOrientation: UIInterfaceOrientation.portrait)
        let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfigurateion)
        
        return session
    }()
    
    var debugText: UILabel?
    
    func startLive(url: String) {
        let stream  = LFLiveStreamInfo()
        stream.url = url
        
        if debugText == nil {
            debugText = UILabel()
            
            if let text = debugText {
                preView.addSubview(text)
                text.snp.makeConstraints({ (maker) in
                    maker.top.equalTo(0)
                    maker.left.equalTo(0)
                    maker.width.greaterThanOrEqualTo(0)
                })
            }
        }
        
        session?.delegate = self
        session?.preView = preView
        session?.captureDevicePosition = AVCaptureDevicePosition.back
        
        session?.beautyFace = false
        session?.showDebugInfo = true
        session?.running = true
        session?.startLive(stream)
    }
    
    func stopLive() {
        
        session?.running = false
        session?.stopLive()
    }
    
    func switchCamera() {
        guard let devicePosition = session?.captureDevicePosition else { return }
        
        session?.captureDevicePosition = (devicePosition == AVCaptureDevicePosition.back) ? AVCaptureDevicePosition.front : AVCaptureDevicePosition.back
    }
    
    @IBAction func btnStart(sender: UIButton) {
        if session?.running == false {
            guard let url = urlText.text else { return }
            
            startLive(url: url)
            
            urlText.isEnabled = false
            
            actionBtn.setTitle("关闭", for: UIControlState.normal)
        } else {
            stopLive()
            
            urlText.isEnabled = true
            
            actionBtn.setTitle("开启", for: UIControlState.normal)
        }
    }
    
    @IBAction func btnSwitch(sender: UIButton) {
        switchCamera()
    }
    
    @IBAction func btnSwitchBeauty(sender: UIButton) {
        guard session?.running == true else { return }
        
        if session?.beautyFace == true {
            session?.beautyFace = false
            
            beautyBtn.setTitle("开启美颜", for: UIControlState.normal)
        } else {
            session?.beautyFace = true
            
            beautyBtn.setTitle("关闭美颜", for: UIControlState.normal)
        }
    }
    
    @IBOutlet private var preView: UIView!
    @IBOutlet private var actionBtn: UIButton!
    @IBOutlet private var beautyBtn: UIButton!
    @IBOutlet private var urlText: UITextField!
    
    func keyboardDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        urlText.frame = CGRect(x: urlText.frame.origin.x, y: keyboardEndFrame.origin.y-urlText.frame.height, width: urlText.frame.width, height: urlText.frame.height)
    }
}

extension AnchorViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension AnchorViewController: LFLiveSessionDelegate {
    public func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
    }
    
    public func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?) {
        guard let text = debugText else { return }
        
        if let debug = debugInfo {
            let info = String.init(format: "%.2f KB/s", debug.bandwidth/1024)
            text.text = info
        }
    }
    
    public func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        guard let text = debugText else { return }
        
        if errorCode == LFLiveSocketErrorCode.connectSocket {
            text.text = "连接socket失败"
        } else if errorCode == LFLiveSocketErrorCode.getStreamInfo {
            text.text = "获取流媒体信息失败"
        } else  if errorCode == LFLiveSocketErrorCode.preView {
            text.text = "预览失败"
        } else if errorCode == LFLiveSocketErrorCode.reConnectTimeOut {
            text.text = "重连超时"
        }
    }
}
