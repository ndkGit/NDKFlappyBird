//
//  ViewController.swift
//  MyFlappyBird
//
//  Created by nidangkun on 2017/9/4.
//  Copyright © 2017年 nidangkun. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode{
    class func unarchiveFromFile (_ file:String) -> SKScene{
        
        let path = Bundle.main.path(forResource: file, ofType: "sks")
        
        let sceneData : Data?
        
        do {
            sceneData = try Data.init(contentsOf: URL.init(fileURLWithPath: path!), options: .mappedIfSafe)
            
        } catch _ {
            sceneData = nil
        }
        
        
        let archiver = NSKeyedUnarchiver.init(forReadingWith: sceneData!)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")

        let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey)
        
        return scene as! SKScene
    
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        
        let scene = TransitionScene.init(size: skView.bounds.size)
            //TransitionScene.unarchiveFromFile("TransitionScene")
        
        skView.showsFPS = true
        
        skView.ignoresSiblingOrder = true
        
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
        }
    }


}

