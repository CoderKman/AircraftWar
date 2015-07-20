//
//  KMTopBarView.swift
//  Flivver
//
//  Created by Kman on 15/7/14.
//  Copyright (c) 2015年 Kman. All rights reserved.
//

import UIKit

class KMTopBarView: UIView {

    @IBOutlet var content: KMTopBarView!
    // 积分容器
    @IBOutlet weak var scoreLabel: UILabel!

    // 血量状态
    @IBOutlet weak var HPProgressView: UIProgressView!
    
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


}
