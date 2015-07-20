//
//  KMAircraft.swift
//  AircraftWar
//
//  Created by Kman on 15/7/17.
//  Copyright (c) 2015年 Kman. All rights reserved.
//

import UIKit

/*
*  飞机模型
*/
class KMAircraft: NSObject {
    
    var image:UIImage?
    var booImage:UIImage  = UIImage(named: "boo")!
    
    var type:Int  = 0
    var x:CGFloat = 0
    var y:CGFloat = 0
    var width:CGFloat = 0
    var height:CGFloat = 0
    
    var speed:CGFloat = 0   // 速度
    var HP :Int    = 100    // 血量
    var cutHP: Int = 10     // 每被打一次减cutHP血量
    
    init(image:UIImage, speed:CGFloat, x:CGFloat, y:CGFloat) {
        
        self.image = image
        self.width = image.size.width
        self.height = image.size.height
        self.x = x
        self.y = y
        self.speed = speed
    }
    
    // 飞机被打中
    func hit(multiple: Int) {
        
        // 减掉相应倍数的血量
        self.HP -= self.cutHP * multiple
        self.makeAnimation("boo", duration: 0.2, startY: 10, moveY: 5)
    }
    
    // 飞机挂掉
    func over() {
        self.makeAnimation("over", duration: 0.8, startY: 0, moveY: 20)
    }
    
    // 创建一个动画
    func makeAnimation(imageNamed: String, duration: NSTimeInterval, startY: CGFloat, moveY: CGFloat) {
        
        let centerx = self.x + self.width * 0.5
        let centery = self.y + self.height * 0.5 + startY
        
        let image = UIImage(named: imageNamed)!
        var overLayer = CALayer()
        overLayer.contents = image.CGImage
        overLayer.bounds = CGRectMake(0, 0, image.size.width, image.size.height)
        overLayer.position = CGPointMake(centerx, centery)
        UIApplication.sharedApplication().keyWindow?.layer.addSublayer(overLayer)
        
        var Animation = CABasicAnimation()
        Animation.duration = duration;
        Animation.toValue = NSValue(CGPoint: CGPointMake(centerx, centery + moveY))
        overLayer.addAnimation(Animation, forKey: "position")
        
        // 动画完成从界面移除
        dispatch_after( dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))),dispatch_get_main_queue()) { () -> Void in
            
            overLayer.removeFromSuperlayer()
        }
    }
}

/*
*  敌机
*/
class KMEnemyAircraft: KMAircraft {
    
    // 根据类型返回对应的敌机
    init(_ type: Int, speed:CGFloat, RandomX: CGFloat) {
        
        let image:UIImage?
        switch type {
        case 3:
            image = UIImage(named: "enemy3")
            
        case 2:
            image = UIImage(named: "enemy2")
            
        default:
            image = UIImage(named: "enemy1")
        }
        
        super.init(image: image!, speed: speed + CGFloat(type), x: RandomX, y: -image!.size.height)
        self.type = type
        self.HP = self.HP + self.type * 30
    }
}

/*
*  我的战机模型
*/
class KMMeAircraft: KMAircraft {
    
    // 创建我的战机，并初始化位置
    init(screenW: CGFloat, screenH: CGFloat) {
        
        let meImage = UIImage(named: "me")!
        super.init(image: meImage, speed: 1, x: (screenW - meImage.size.width) / 2.0, y: screenH - meImage.size.height)
    }
    
    // 飞机被打中
    override func hit(multiple: Int) {
        
        // 减掉相应倍数的血量
        self.HP -= self.cutHP * multiple
        self.makeAnimation("boo", duration: 0.3, startY: -10, moveY: 0)
    }
    
    // 飞机挂掉
    override func over() {
        self.makeAnimation("over", duration: 2.0, startY: 0, moveY: 0.2)
        
    }
}
