//
//  startGameScene.swift
//  bababomb
//
//  Created by Neptune on 5/1/15.
//  Copyright (c) 2015 Sitro Consulting Group. All rights reserved.
//

import Foundation
import SpriteKit

class StartGameScene: SKScene {
    
    var imageList = ["playerIcon.png", "sunIcon.png", "planetIcon.png"]
    let maxImages = 2
    var imageIndex: NSInteger = 0
    
    let label = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
    let label1 = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
    let label2 = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
    let label3 = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
    let label4 = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
    let label5 = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
    let label6 = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
    let label7 = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
    let label8 = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
    
    func swipedRight(sender:UISwipeGestureRecognizer){
        println("swiped right")
    
    }
    
    func swipedLeft(sender:UISwipeGestureRecognizer){
        println("swiped left")
    }
    
    override func didMoveToView(view: SKView) {
        
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedRight:"))
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)
        
        
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedLeft:"))
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)
        

    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches{
            if (touch.tapCount == 2){
                let location = touch.locationInNode(self)
                let scene = GameScene(size: size)
                scene.scaleMode = .ResizeFill
                scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                self.view?.presentScene(scene)
            }
        }
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        let bg = SKSpriteNode(imageNamed: "background")
        println("test")
        
        bg.size.height = self.size.height
        bg.size.width = self.size.width
        addChild(bg)
        let scene = GameScene(size: size)
        scene.scaleMode = .ResizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        var snowEmitterNode = SKEmitterNode(fileNamed: "SnowParticles.sks")
        self.addChild(snowEmitterNode)
        
        var imageView : UIImageView
        imageView  = UIImageView(frame:CGRectMake(10, 50, 100, 300))
        
        imageView.image = UIImage(named:"earth")
        self.view?.addSubview(imageView)

        var message = "Gravity Pong"
        var message1 = "The objective: Tap the screen to propel Earth away from disaster. "
        var message2 = "In order to stay alive, use the blackholes gravitational fields to keep balanced. "
        var message3 = "If you hit a star you will explode. "
        var message4 = "Planets will bump you out of your trajectory. "
        var message5 = "If you hit a wormhole, you will experience vertigo. "
        var message6 = "Get to close to a blackhole and you will spaghettify. "
        var message7 = "Collect flying saucers for a secret bonus."
        var message8 = "Swipe right to learn the pieces. Tap twice to start!"
        
        
        label.text = message
        label.fontSize = 32
        label.fontColor = SKColor.whiteColor()
        label.position = CGPoint(x: 0, y: 100)
        
        label1.text = message1
        label1.fontSize = 32
        label1.fontColor = SKColor.greenColor()
        label1.position = CGPoint(x: 0, y: 60)
        
        label1.text = message2
        label1.fontSize = 16
        label1.fontColor = SKColor.whiteColor()
        label1.position = CGPoint(x: 0, y: 40)
        
        label2.text = message3
        label2.fontSize = 16
        label2.fontColor = SKColor.whiteColor()
        label2.position = CGPoint(x: 0, y: 20)
        
        label3.text = message4
        label3.fontSize = 16
        label3.fontColor = SKColor.whiteColor()
        label3.position = CGPoint(x: 0, y: 0)
        
        label4.text = message5
        label4.fontSize = 16
        label4.fontColor = SKColor.whiteColor()
        label4.position = CGPoint(x: 0, y: -20)
        
        label5.text = message6
        label5.fontSize = 16
        label5.fontColor = SKColor.whiteColor()
        label5.position = CGPoint(x: 0, y: -40)
        
        label6.text = message7
        label6.fontSize = 16
        label6.fontColor = SKColor.whiteColor()
        label6.position = CGPoint(x: 0, y: -60)
        
        label7.text = message8
        label7.fontSize = 16
        label7.fontColor = SKColor.greenColor()
        label7.position = CGPoint(x: 0, y: -80)
        
        addChild(label)
        addChild(label1)
        addChild(label2)
        addChild(label3)
        addChild(label4)
        addChild(label5)
        addChild(label6)
        addChild(label7)
        addChild(label8)
        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}