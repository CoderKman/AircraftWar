//
//  KMTopBarView.swift
//  Flivver
//
//  Created by Kman on 15/7/14.
//  Copyright (c) 2015年 Kman. All rights reserved.
//

import UIKit

protocol KMTopBarViewDelegate : NSObjectProtocol {
    //代理方法
    func operationClick()
}

class KMTopBarView: UIView {

    @IBOutlet var content: KMTopBarView!
    // 积分容器
    @IBOutlet weak var scoreLabel: UILabel!

    // 血量状态
    @IBOutlet weak var HPProgressView: UIProgressView!
    
    // 当前关卡
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var pauseBtn: UIButton!
    //声明代理属性
    var delegate : KMTopBarViewDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
        let nib = UINib(nibName: "KMTopBarView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        
        content.frame = bounds
        self.addSubview(content)
    }
    
    // 点击暂停
    @IBAction func pauseClick(sender: UIButton) {

        var title = self.pauseBtn.titleLabel?.text == "暂停" ? "继续" : "暂停"
        self.pauseBtn.setTitle(title, forState: UIControlState.Normal)
        self.delegate?.operationClick();
    }
    

}
