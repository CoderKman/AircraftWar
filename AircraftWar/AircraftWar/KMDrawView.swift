//
//  KMDrawView.swift
//  Flivver
//
//  Created by Kman on 15/7/12.
//  Copyright (c) 2015年 Kman. All rights reserved.
//

import UIKit

class KMDrawView: UIView {
    
    weak var topBarView:KMTopBarView!
    
    var link:CADisplayLink?     // 定时器
    
    var bgImage1:UIImage!       // 背景1
    var bgImage2:UIImage!       // 背景2
    var bgImageY:CGFloat = 0    // 背景Y轴
    
    var meAircraft:KMAircraft?        // 我的战机
    var enemyAircrafts:Set<KMAircraft> = []  // 所有敌机
    var bullets:Set<KMBullet> = [] // 所有子弹
    
    let screenW = UIScreen.mainScreen().bounds.width
    let screenH = UIScreen.mainScreen().bounds.height
    
    var allTime:Int  = 0        // 全局时间
    let updateTime:Int = 60 * 10 // 每隔n秒,升一级
    var level:Int      = 1      // 当前等级
    var score:Int      = 0      // 积分
    let ScoreStep      = 100    // 每次加100积分
    
    // 线程
    let otherQueue: NSOperationQueue = NSOperationQueue()
    let touchQueue: NSOperationQueue = NSOperationQueue()
    let updateEnemysQueue: NSOperationQueue = NSOperationQueue()
    
    // 初始化
    override func awakeFromNib() {
        self.setUp()
    }
    
    func setUp() {
        
        // 添加定时器
        var link = CADisplayLink(target: self, selector: "change:")
        link.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        self.link = link;
        
        // 初始化界面元素
        // 添加背景
        self.bgImage1 = UIImage(named: "bg_01")
        self.bgImage2 = UIImage(named: "bg_02")
        
        // 添加我的战机
        self.meAircraft = KMMeAircraft(screenW: self.screenW, screenH: self.screenH)
        
        // 给我的战机添加手势
        var panGesture = UIPanGestureRecognizer(target: self, action: "pan:")
        self.addGestureRecognizer(panGesture)
        
        // 初始化topBar
//        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("KMTopBarView", owner: self, options: nil)
//        var topBar = nibs.lastObject as! KMTopBarView
        var topBar = KMTopBarView(frame: CGRectMake(0, 0, screenW, 45))
        self.addSubview(topBar)
        self.topBarView = topBar
    }
    
    // 让我的战机绑定拖动手势
    func pan(event:UIPanGestureRecognizer){
        
        if self.meAircraft != nil {
            self.touchQueue.addOperationWithBlock { () -> Void in
                
                let offset = event.translationInView(self)
                self.meAircraft!.x += offset.x
                self.meAircraft!.y += offset.y
                
                // 复位
                event.setTranslation(CGPointZero, inView: self)
//                println(NSThread.currentThread())
            }
        }
    }
    
    // 定时刷新
    func change(link:CADisplayLink){
        
        if self.meAircraft == nil{
            self.paused()
            return
        }
        
        self.otherQueue.addOperationWithBlock { () -> Void in
            // 最多8个关卡
            if self.level > 8
            {
                self.paused()
            }
            // 刷新时间
            self.setTime()
            
            // 添加敌机
            self.creatEnemyAircraft()
            
            // 添加子弹
            if self.allTime % 20 == 0{
                self.creatBullet()
            }
        }
        
        self.updateEnemysQueue.addOperationWithBlock { () -> Void in
            // 刷新所有敌机
            self.updateAllEnemyAircrafts()
        }
        
        self.setNeedsDisplay()
    }
    
    // 刷新界面
    override func drawRect(rect: CGRect) {
        
        // 刷新背景
        self.updateBgImage()
        
        // 重绘所用敌机
        self.redrawAllEnemys()
        
        // 刷新所有子弹
        self.updateAllBullets()
        
        // 刷新我的战机
        self.updateMe()
        
    }
    // 暂停
    func paused() {
        self.link?.paused = true
    }
    // 开始
    func goOn() {
        self.link?.paused = false
    }
    
    // 更新时间
    func setTime() {
        
        // 每隔self.updateTime秒就升一级，加快速度 (CADisplayLink 刷新的速度是 1/60秒)
        if  ++self.allTime % self.updateTime == 0 {
            self.level++
        }
        println("等级：" + String(self.level))
    }
    
    // 刷新积分
    func updateScore(score: Int) {
        self.score += score
        self.topBarView.scoreLabel.text = String(self.score)
    }
    // 刷新生命值
    func updateHPProgress() {
        
        if let meAircraft = self.meAircraft {
            self.topBarView.HPProgressView.setProgress(Float(meAircraft.HP) / 100.0, animated: true)
        }
    }
    // 刷新背景
    func updateBgImage(){
        
        // 改变Y值
        self.bgImageY++
        if self.bgImageY == screenH {
            self.bgImageY = 0
            
            // 交换指针
            let tempBg = self.bgImage1
            self.bgImage1 = self.bgImage2
            self.bgImage2 = tempBg
        }
        // 重画背景
        self.bgImage1?.drawInRect(CGRectMake(0, self.bgImageY, screenW, screenH))
        self.bgImage2?.drawInRect(CGRectMake(0, self.bgImageY - screenH, screenW, screenH))
        
    }
    
    // 刷新我的战机
    func updateMe(){
        if let meAircraft = self.meAircraft {
            if meAircraft.HP <= 0  {
                meAircraft.over()
                self.meAircraft = nil
            }else{
                meAircraft.image!.drawInRect(CGRectMake(meAircraft.x, meAircraft.y, meAircraft.width, meAircraft.height))
            }
        }
    }
    
    // 生成子弹
    func creatBullet() {
        
        for i in 0..<self.level {
            let Bullet = KMBullet(speed: CGFloat(self.level+8), x: self.meAircraft!.x + self.meAircraft!.width * 0.5 - 3, y: self.meAircraft!.y - CGFloat(20 * i))
            self.bullets.insert(Bullet)
        }
    }
    
    // 刷新所有子弹
    func updateAllBullets() {
        
        for bullet in self.bullets {
            // 超出屏幕消失
            if bullet.y <= 0
            {
                self.bullets.remove(bullet)
                continue
            }
            
            bullet.y -= bullet.speed
            bullet.image.drawInRect(CGRectMake(bullet.x, bullet.y, bullet.width, bullet.height))
        }
    }
    
    // 随机生成敌机
    func creatEnemyAircraft(){
        
        var type: Int = 0
        
        if(self.allTime % (400 - self.level * 40) == 0){
            type = 3
            
        }else if(self.allTime % (200 - self.level * 20) == 0){
            type = 2
            
        }else if(self.allTime % (60  - self.level * 6) == 0){
            type = 1
        }
        if type > 0 {
            self.enemyAircrafts.insert(KMEnemyAircraft(type, speed: CGFloat(self.level / 2), RandomX: self.getRandomX()));
        }
        
    }
    // 刷新所有敌机
    func updateAllEnemyAircrafts() {
        
        for enemyAircraft in self.enemyAircrafts {
            
            // 血量小于0 或 超出屏幕消失
            if enemyAircraft.HP <= 0 || enemyAircraft.y >= self.screenH{
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    enemyAircraft.over()
                })
                self.enemyAircrafts.remove(enemyAircraft)
                continue
                
            }else{
                enemyAircraft.y += enemyAircraft.speed
                
            }
            
            // 如果撞上我的战机，敌机就立马销毁
            if let meAircraft = self.meAircraft{
                if (meAircraft.y < enemyAircraft.y) && ((meAircraft.y + meAircraft.height) > enemyAircraft.y) && ((meAircraft.x + meAircraft.width) > enemyAircraft.x) && (meAircraft.x < (enemyAircraft.x + enemyAircraft.width)) {
                    
                    
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            
                            enemyAircraft.over()
                            self.enemyAircrafts.remove(enemyAircraft)
                            
                            meAircraft.hit(enemyAircraft.type)
                            self.updateHPProgress()
                    })

                }
            }
            // 如果子弹击中飞机
            for bullet in self.bullets {
                if (bullet.y < enemyAircraft.y) && ((bullet.y + bullet.height) > enemyAircraft.y) && ((bullet.x + bullet.width) > enemyAircraft.x) && (bullet.x < (enemyAircraft.x + enemyAircraft.width)) {
                    
                    // 子弹消失
                    self.bullets.remove(bullet)
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        
                        enemyAircraft.hit(5)
                        // 加10,20,30积分
                        self.updateScore(self.ScoreStep * enemyAircraft.type)
                    })
                }
            }
            
        }
    }
    // 重绘所用敌机
    func redrawAllEnemys() {
        for (index, enemyAircraft) in enumerate(self.enemyAircrafts){
            enemyAircraft.image?.drawInRect(CGRectMake(enemyAircraft.x, enemyAircraft.y, enemyAircraft.width, enemyAircraft.height))
        }
    }
    
    // 随机返回一个X轴的点
    func getRandomX() ->CGFloat{
        
        return CGFloat(arc4random_uniform(UInt32(self.screenW)))
    }
    
    
}
