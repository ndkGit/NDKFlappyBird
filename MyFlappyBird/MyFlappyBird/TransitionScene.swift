//
//  TransitionScene.swift
//  MyFlappyBird
//
//  Created by nidangkun on 2017/9/4.
//  Copyright © 2017年 nidangkun. All rights reserved.
//


import SpriteKit

class TransitionScene: SKScene {

    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.white
        
        let gameLab = SKLabelNode.init(fontNamed: "Chalkduster")
        gameLab.text = "Welcome!"
        gameLab.fontColor = UIColor.black
        gameLab.fontSize = 20
        gameLab.position = CGPoint.init(x: self.frame.midX, y: self.frame.midY)
        
        self.addChild(gameLab)
        
        let promptLab = SKLabelNode.init(fontNamed: "Chalkduster")
        
        self.addChild(promptLab)
        
        promptLab.text = "Touch to start"
        promptLab.fontColor = UIColor.black
        promptLab.fontSize = 15
        
        promptLab.position = CGPoint.init(x: self.frame.midX, y: self.frame.midY - 80)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let csTransition = SKTransition.doorsOpenHorizontal(withDuration:1)
        
        let gameScene = GameScene.init(size: self.size)
            
            //GameScene.unarchiveFromFile("GameScene")
        
        self.scene?.view?.presentScene(gameScene, transition: csTransition)

    }
    
    
}
