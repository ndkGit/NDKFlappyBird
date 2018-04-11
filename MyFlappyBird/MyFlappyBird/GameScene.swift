//
//  GameScene.swift
//  MyFlappyBird
//
//  Created by nidangkun on 2017/9/4.
//  Copyright © 2017年 nidangkun. All rights reserved.
//

import UIKit
import SpriteKit



class GameScene: SKScene ,SKPhysicsContactDelegate{
    var pipePair = SKNode()
    
    var birdNode : SKSpriteNode!
    
    var groundNode = SKSpriteNode()
    
    var skyNode = SKSpriteNode()
    
    var scoreNode = SKLabelNode()
    
    var canRestart = Bool()
    
    var skyColor = UIColor()
    
    var allMovingStaff = SKNode()
    
    var pipeUpTexture = SKTexture()
    
    var pipeDownTexture = SKTexture()
    
    var pipeMoveAction = SKAction()
    
    let userDefalut = UserDefaults.standard
    
    
    let birdCategory :  UInt32 = 1 << 0
    let worldCategory : UInt32 = 1 << 1
    let pipesCategory : UInt32 = 1 << 2
    let scoreCategory : UInt32 = 1 << 3
    
    //分数
    var score = NSInteger()
    
    var flyAction = SKAction()
    
    var birdStopFly : SKTexture!
    
    var endNode : SKSpriteNode!
    
    var currentScore = SKLabelNode()

    var highScore = SKLabelNode()
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.gravity = CGVector.init(dx: 0, dy: -5)
        
        self.physicsWorld.contactDelegate = self
        
        skyColor = SKColor(red: 81.0/255.0, green: 192.0/255.0, blue: 201.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor
        
        self.addChild(allMovingStaff)
        
        
        let groundTexture = SKTexture.init(imageNamed: "land")
        
        groundTexture.filteringMode = .nearest
        
        let groundMove = SKAction.moveBy(x: -groundTexture.size().width*2, y: 0, duration: TimeInterval(0.02*groundTexture.size().width*2))
        
        let groundReset = SKAction.moveBy(x: groundTexture.size().width*2, y: 0, duration: 0)
        
        let repeatGroundAct = SKAction.sequence([groundMove,groundReset])
        
        let groundMoveRepeatAction = SKAction.repeatForever(repeatGroundAct)
        
        
        for i in 0 ..< 2 + Int(self.frame.size.width/groundTexture.size().width*2){
            
            let groundNode = SKSpriteNode.init(texture: groundTexture)
            
            groundNode.setScale(2)
            groundNode.position = CGPoint.init(x: CGFloat(i) * groundNode.size.width, y: groundNode.size.height/2)
            
            groundNode.run(groundMoveRepeatAction)
            
            allMovingStaff.addChild(groundNode)
            
            groundNode.physicsBody = SKPhysicsBody.init(rectangleOf: groundNode.size)
            groundNode.physicsBody?.categoryBitMask = worldCategory
            //sprite.physicsBody?.contactTestBitMask = birdCategory
            groundNode.physicsBody?.isDynamic = false
            
        }
        
        
        let skyTexture = SKTexture.init(imageNamed: "sky")
        skyTexture.filteringMode = .linear
        
        let skyMove = SKAction.moveBy(x: -skyTexture.size().width*2, y: 0, duration: TimeInterval(0.1*skyTexture.size().width*2))
        let skyReset = SKAction.moveBy(x: skyTexture.size().width*2, y: 0, duration: 0)
        
        let repeatSkyAct = SKAction.repeatForever(SKAction.sequence([skyMove,skyReset]))
        


        for i in 0 ..< 3{
            let skyNode = SKSpriteNode.init(texture: skyTexture)
            skyNode.setScale(2)
            skyNode.zPosition = -20
            skyNode.position = CGPoint.init(x: CGFloat(i)*skyNode.size.width, y: skyNode.size.height / 2.0 + groundTexture.size().height * 2.0)
            
            skyNode.run(repeatSkyAct)
            
            allMovingStaff.addChild(skyNode)
            
        }
        
        //管子
        pipeUpTexture = SKTexture.init(imageNamed: "PipeUp")
        pipeUpTexture.filteringMode = .nearest
        
        pipeDownTexture = SKTexture.init(imageNamed: "PipeDown")
        pipeDownTexture.filteringMode = .nearest
        
        
        let pipeMoveDis = CGFloat(self.frame.size.width + pipeUpTexture.size().width*3 )
        
        let pipeMoveAct = SKAction.moveBy(x: -pipeMoveDis , y: 0, duration: TimeInterval(0.01*pipeMoveDis))
        
        let pipeRemove = SKAction.removeFromParent()
        
        pipeMoveAction = SKAction.repeatForever(SKAction.sequence([pipeMoveAct,pipeRemove]))
        
        
        let assPipePair = SKAction.run(assemblePipePair)
        
        let delay = SKAction.wait(forDuration: 2)
        
        let pipeMoving = SKAction.repeatForever(SKAction.sequence([assPipePair,delay]))
        
        allMovingStaff.addChild(pipePair)
        
        self.run(pipeMoving)
        
        let bird1 = SKTexture.init(imageNamed: "bird-01")
        bird1.filteringMode = .nearest
        
        birdStopFly = SKTexture.init(imageNamed: "bird-02")
        birdStopFly.filteringMode = .nearest
        
        let bird3 = SKTexture.init(imageNamed: "bird-03")
        bird3.filteringMode = .nearest
        
        flyAction = SKAction.repeatForever(SKAction.animate(with: [bird1,birdStopFly,bird3], timePerFrame: 0.1))
        
        birdNode = SKSpriteNode.init(texture: birdStopFly)
        birdNode.run(flyAction)
        birdNode.setScale(2)
        birdNode.position = CGPoint.init(x: self.frame.size.width*0.3, y: self.frame.size.height*0.6)
        
        self.addChild(birdNode)
        
        
        birdNode.physicsBody = SKPhysicsBody.init(circleOfRadius: birdNode.size.height/2)
        
        birdNode.physicsBody?.isDynamic = true
        birdNode.physicsBody?.allowsRotation = false
        
        birdNode.physicsBody?.categoryBitMask = birdCategory
        
        // collisionBitMask 决定与谁碰撞 停止, contactTestBitMask 决定 解除碰撞 的物体
        
        birdNode.physicsBody?.collisionBitMask = pipesCategory | worldCategory
        birdNode.physicsBody?.contactTestBitMask = pipesCategory | worldCategory
        
        score = 0
        
        scoreNode = SKLabelNode.init(fontNamed: "MarkerFelt-Wide")
        
        scoreNode.position = CGPoint( x: self.frame.midX, y: 3 * self.frame.size.height / 4 )
        scoreNode.zPosition = 50
        scoreNode.text = String(score)
        self.addChild(scoreNode)
        
    }
    
    func resetFlyAnimation(){
        birdNode.removeAllActions()
        
        birdNode.run(flyAction)
        
    }

    func assemblePipePair (){
        let pipe = SKNode.init()
        
        pipe.position = CGPoint.init(x: self.frame.size.width + pipeUpTexture.size().width*2, y: 0)
        pipe.zPosition = -10
        
        let height = UInt32( self.frame.size.height / 4)
        let randomY = Double(arc4random_uniform(height) + height)
       
       let pipeUpNode = SKSpriteNode.init(texture: pipeUpTexture)
        pipeUpNode.setScale(2)
        pipeUpNode.position = CGPoint.init(x: 0, y: randomY)
        
        pipe.addChild(pipeUpNode)
        
        pipeUpNode.physicsBody = SKPhysicsBody.init(rectangleOf: pipeUpNode.size)
        pipeUpNode.physicsBody?.categoryBitMask = pipesCategory
        pipeUpNode.physicsBody?.isDynamic = false
        pipeUpNode.physicsBody?.contactTestBitMask = birdCategory
        
        let gapHeight = 170.0
        
        let pipeDownNode = SKSpriteNode.init(texture: pipeDownTexture)
        pipeDownNode.setScale(2)
        pipe.addChild(pipeDownNode)
        
        pipeDownNode.position = CGPoint.init(x: 0, y: randomY + Double(pipeDownNode.size.height) + gapHeight)
        
        pipeDownNode.physicsBody = SKPhysicsBody.init(rectangleOf: pipeDownNode.size)
        pipeDownNode.physicsBody?.categoryBitMask = pipesCategory
        pipeDownNode.physicsBody?.isDynamic = false
        pipeDownNode.physicsBody?.contactTestBitMask = birdCategory
        
        let scoreContactNode = SKSpriteNode.init(color: UIColor.init(), size: CGSize.init(width: 10, height: gapHeight))
        pipe.addChild(scoreContactNode)
        scoreContactNode.setScale(2)
        scoreContactNode.position = CGPoint.init(x: Double(pipeDownNode.frame.maxX), y: randomY  + gapHeight )
        
        scoreContactNode.physicsBody = SKPhysicsBody.init(rectangleOf:scoreContactNode.size)
        
        scoreContactNode.physicsBody?.categoryBitMask = scoreCategory
        scoreContactNode.physicsBody?.isDynamic = false
        scoreContactNode.physicsBody?.contactTestBitMask = birdCategory
        
        pipe.run(pipeMoveAction)
        
        pipePair.addChild(pipe)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //sknode.speed 默认值 为 1
        if allMovingStaff.speed > 0 {
            //增加向上的推力
            birdNode.physicsBody?.velocity = CGVector.init(dx: 0, dy: 0)
            birdNode.physicsBody?.applyImpulse(CGVector.init(dx: 0, dy: 30))
            
        }else if canRestart{
            self.resetScene()
        }
        
    }
    
    func resetScene(){
        endNode.removeAllChildren()
        endNode.removeFromParent()
    
        birdNode.position = CGPoint(x: self.frame.size.width / 2.5, y: self.frame.midY)
        
        birdNode.physicsBody?.velocity = CGVector.init(dx: 0, dy: 0)
        birdNode.speed = 1
        birdNode.zRotation = 0
        
        
        birdNode.run(flyAction)
        
        pipePair.removeAllChildren()
        
        canRestart = false
        
        score = 0
        
        scoreNode.text = String(score)
        
        allMovingStaff.speed = 1
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        //print("bird.dy ====>>>>\(birdNode.physicsBody?.velocity.dy)")
        let rValue = birdNode.physicsBody!.velocity.dy * ( birdNode.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 )
        birdNode.zRotation = min( max(-1, rValue), 0.5 )
    }
    
    
    
///delegate
    func didBegin(_ contact: SKPhysicsContact) {
        if allMovingStaff.speed > 0 {
            let contactACat = contact.bodyA.categoryBitMask
            
            let contactBCat = contact.bodyB.categoryBitMask
            
            
            if ((contactACat == birdCategory && contactBCat == scoreCategory) || (contactBCat == birdCategory && contactACat == scoreCategory) ) {
                
                
                score += 1
                
                scoreNode.text = String(score)
                
                // Add a little visual feedback for the score increment
                scoreNode.run(SKAction.sequence([SKAction.scale(to: 1.5, duration:TimeInterval(0.1)), SKAction.scale(to: 1.0, duration:TimeInterval(0.1))]))
            }else{
                //gameover
                
                allMovingStaff.speed = 0
                //设置 掉落在 地面上
                
                birdNode.removeAllActions()
                //静止图
                birdNode.texture = birdStopFly
                
                let redSkyColor = SKAction.run({
                    self.backgroundColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1.0)
                })
                
                let originSkyColor = SKAction.run {
                    self.backgroundColor = self.skyColor
                }
                
                self.removeAction(forKey: "flashEnd")
                
                self.run(SKAction.sequence([SKAction.repeat(SKAction.sequence([redSkyColor,SKAction.wait(forDuration: 0.05),originSkyColor,SKAction.wait(forDuration: 0.05)]), count: 4),SKAction.run {
                        self.canRestart = true
                    }]), withKey: "flashEnd")
                
                
                //加入一个结束动画 显示最高分
                self.endAnimation()
                
                
            }
        }
        
    }
    
    func endAnimation(){
        //endNode.removeFromParent()
        let board = SKTexture.init(imageNamed: "scoreboard")
        board.filteringMode = .linear
        
        endNode = SKSpriteNode.init(texture: board)
        endNode.zPosition = 100
        //endNode.alpha = 1
        self.addChild(endNode)
        
        endNode.position = CGPoint.init(x: self.frame.midX, y: self.frame.midY)
        
        
        //最低分，最高分
        currentScore.fontName = "Arial"
        currentScore.fontSize = 20
        currentScore.fontColor = UIColor.red
        currentScore.zPosition = 20
        
        endNode.addChild(currentScore)
        
        currentScore.text = String(score)
        currentScore.position = CGPoint.init(x: endNode.size.width - 144, y: 18)
        currentScore.horizontalAlignmentMode = .right
        
        
        self.storeHighScore(score)
        
        highScore.fontName = "Arial"
        highScore.fontSize = 20
        highScore.fontColor = UIColor.red
        highScore.zPosition = 20
        endNode.addChild(highScore)
        
        let historyHigh = userDefalut.value(forKey: "highScore") as! Int
        
        
        //print("score===\(score),history==>>\(historyHigh)")
        
        //print("history==>>>\(historyHigh)")
        
        highScore.text = String(historyHigh)
        highScore.position = CGPoint.init(x: endNode.size.width - 144, y: -24)
        highScore.horizontalAlignmentMode = .right
        
        
        
        
    }
    
    func storeHighScore (_ highScore:Int){
        
        guard let preHighScore = userDefalut.value(forKey: "highScore") else {
            userDefalut.setValue(0, forKey: "highScore")
            print("NoHighScore,already Set Zero")
            return  }
        
        if (preHighScore as! Int) < highScore {
            userDefalut.setValue(highScore, forKey: "highScore")
        }
    }
    
    
}
