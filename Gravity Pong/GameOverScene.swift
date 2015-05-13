//
//  gameOverScene.swift
//  bababomb
//
//  Created by Neptune on 5/1/15.
//  Copyright (c) 2015 Sitro Consulting Group. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    init(size: CGSize, won:Bool, counter:Int) {
        super.init(size: size)
        let scene = GameScene(size: size)
        scene.scaleMode = .ResizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addBGToScene()
        var snowEmitterNode = SKEmitterNode(fileNamed: "SnowParticles.sks")
        self.addChild(snowEmitterNode)

        // established vars for highscore
        var defaults=NSUserDefaults()
        var highscore=defaults.integerForKey("highscore")
        
        if(counter>highscore)
        {
            defaults.setInteger(counter, forKey: "highscore")
        }
        var highscoreshow=defaults.integerForKey("highscore")
        

        var message = won ? "Wow, you beat the game!" : "Ouch, try again! Score: \(counter - 1)!"
        let label = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
        label.text = message
        label.fontSize = 30
        label.fontColor = SKColor.whiteColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        let lblHighScore = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
        lblHighScore.text="Your High Score: \(highscoreshow - 1)"
        lblHighScore.fontSize = 20
        lblHighScore.fontColor = SKColor.greenColor()
        lblHighScore.position = CGPoint(x: size.width/2, y: size.height/2 - 40)
        addChild(lblHighScore)
                
    runAction(SKAction.sequence([
    SKAction.waitForDuration(3.0),
    SKAction.runBlock() {
    
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        let scene = GameScene(size: size)
        scene.scaleMode = .ResizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.view?.presentScene(scene, transition:reveal)
    }
    ]))
    
    }
    
    required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
    }
    func addBGToScene(){
        //bg.size.height = self.size.height
        //bg.size.width = self.size.width
        //addChild(bg)
        self.backgroundColor = SKColor.blackColor()
    }
}
