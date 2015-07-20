//
//  KMBullet.swift
//  Flivver
//
//  Created by Kman on 15/7/14.
//  Copyright (c) 2015年 Kman. All rights reserved.
//

import UIKit

/*
*  子弹模型
*/
class KMBullet: NSObject {
    
    var image:UIImage
    var x:CGFloat = 0
    var y:CGFloat = 0
    var width:CGFloat = 0
    var height:CGFloat = 0
    
    var speed:CGFloat = 0   // 速度
    
    init(speed:CGFloat, x:CGFloat, y:CGFloat) {
        
        self.image  = UIImage(named: "bullet")!
        self.width  = self.image.size.width
        self.height = self.image.size.height
        self.x = x
        self.y = y
        self.speed = speed
    }
}
