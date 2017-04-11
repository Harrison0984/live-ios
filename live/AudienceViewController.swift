//
//  AudienceViewController.swift
//  live
//
//  Created by heyunpeng on 2016/12/26.
//  Copyright © 2016年 heyunpeng. All rights reserved.
//

import Foundation
import IJKMediaFramework

class AudienceViewController: UIViewController {
    @IBOutlet var preview: UIView!
    @IBOutlet var urlText: UITextField!
    @IBOutlet var actionBtn: UIButton!
    
    private var player: IJKFFMoviePlayerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        urlText.addTarget(urlText, action: #selector(resignFirstResponder), for: UIControlEvents.editingDidEndOnExit)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        player?.shutdown()
        player?.view.removeFromSuperview()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        urlText.frame = CGRect(x: urlText.frame.origin.x, y: keyboardEndFrame.origin.y-urlText.frame.height, width: urlText.frame.width, height: urlText.frame.height)
    }
    
    @IBAction func btnStart(sender: UIButton) {
        guard let url = urlText.text else { return }
        
        if player == nil {
            let option = IJKFFOptions.byDefault()
            option?.setPlayerOptionValue("1", forKey: "videotoolbox")
            
            let moviePlayer = IJKFFMoviePlayerController.init(contentURLString: url, with: option)
            
            moviePlayer?.view.frame = preview.bounds
            moviePlayer?.scalingMode = IJKMPMovieScalingMode.aspectFill
            moviePlayer?.shouldAutoplay = true
            if let subView = moviePlayer?.view {
                preview.addSubview(subView)
            }
            preview.bringSubview(toFront: urlText)
            preview.bringSubview(toFront: actionBtn)
            
            moviePlayer?.prepareToPlay()
            player = moviePlayer
            
            actionBtn.setTitle("关闭", for: UIControlState.normal)
            
        } else {
            player?.shutdown()
            player?.view.removeFromSuperview()
            player = nil
            
            actionBtn.setTitle("开启", for: UIControlState.normal)
        }
    }
}

extension AudienceViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
