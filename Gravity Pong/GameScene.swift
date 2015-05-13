//
//  GameScene.swift
//  Gravity Pong
//
//  Created by Neptune on 5/11/15.
//  Copyright (c) 2015 Sitro Consulting Group. All rights reserved.
//


import SpriteKit

// SETS UP EXTENSION TO SCENE FOR RANDOM PICKS WITHIN AN ARRAY
extension Array {
    func randomArrayPick() -> T {
        let randomIndex = Int(rand()) % count
        return self[randomIndex]
    }
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene , SKPhysicsContactDelegate {
    
    // GLOBAL VARIABLE ESTABLISHMENT
    let player = SKSpriteNode(imageNamed: "earth")
    let ground = SKSpriteNode(imageNamed: "ground")
    let leftSideOfScene = SKSpriteNode(imageNamed: "ground")
    let rightSideOfScene = SKSpriteNode(imageNamed: "ground")
    let sky = SKSpriteNode(imageNamed: "ground")
    var endOfScreenRight = CGFloat()
    var endOfScreenLeft = CGFloat()
    var gameOver = false
    var counter = 0
    var clickUpNum:CGFloat = 13
    var timer = NSTimer()
    var controlFlipTimer = NSTimer()
    var wormholeTimer = NSTimer()
    var gravityTimer = NSTimer()
    var addMonsterTimer = NSTimer()
    var controlIsNormal = true
    var scoreLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
    var alienCounterLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
    var fullControlLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
    var fullControlLabel1 = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
    var isControlNormal = true
    var isGravityNormal = true
    var isStarPowerOn = false
    var alienCollectorCounter = 0
    var alien = SKSpriteNode(imageNamed: "alien")
    var isFullControlEnabled = false
    var fireEmitterNode = SKEmitterNode(fileNamed: "FireEmitter.sks")
    var snowEmitterNode = SKEmitterNode(fileNamed: "SnowParticles.sks")
    var explodeStars = false

    
    // BIT MASK CONFIGURATION FOR COLLISION DETECTIONS
    enum ColliderType:UInt32{
        case None = 0
        case Player = 1
        case Monster = 2
        case Ground = 3
        case Wormhole = 4
        case Sun = 5
        case Planet = 6
        case Alien = 7
        case LeftSideEdge = 8
        case RightSideEdge = 9
        case Blackhole = 10
        case BlackHoleGravity = 11
        case StarPowerUp = 12
        case Projectile = 14
        case PlayerWithStarPower = 15
    }
    
    // SETS UP SCREEN WHERE IF A USER CLICKS ANYWHERE ON IT, IT WILL RAISE THE PLAYER 13 CGVECTOR POINTS
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        println("\(isFullControlEnabled)")
        if (isFullControlEnabled != true){
            if (isControlNormal == true && isGravityNormal == true){
                for touch: AnyObject in touches{
                    let location = touch.locationInNode(self)
                    player.physicsBody?.velocity = CGVectorMake(0,0)
                    player.physicsBody?.applyImpulse(CGVectorMake(0, 13))
                }
            }else if (isControlNormal == false){
                for touch: AnyObject in touches{
                    let location = touch.locationInNode(self)
                    player.physicsBody?.velocity = CGVectorMake(0,0)
                    player.physicsBody?.applyImpulse(CGVectorMake(0, -13))
                }
            }
        }
        else{
            if (isStarPowerOn == true){
            for touch: AnyObject in touches{
                let location = touch.locationInNode(self)
                if (touch.tapCount == 2){
                //func to shoot a monster
                    println("star power!")
                    starPowerActive()
                    explodeStars = true
                    }
                }
            }
        }
        
    }
    
    override func didMoveToView(view: SKView) {
        
        // CALLS ON FUNCTION TO ADD BACKGROUND TO SCENE
        addBGToScene()
        self.addChild(snowEmitterNode)
        
        // CALLS ON FUNCTIONS TO ESTABLISH SCENES BORDER
        setupEndOfScreens()
        addRightSideOfScene()
        addSkyToScene()
        addGroundToScene()
        addLeftSideOfScene()
        
        // CALLS ON FUNCTION TO ADD PLAYER TO SCENE
        addPlayerToScene()
        
        // CALLS ON FUNCTION TO ADD SCORE LABEL TO SCENE
        addScoreLabel()
        addAlienCounterLabel()
        
        // ESTABLISHES GRAVITY AND CONTACT DELEGATION FOR SCENE
        physicsWorld.gravity = CGVectorMake(0, -2)
        physicsWorld.contactDelegate = self
        
        // RUNS ADD MOSNTER AND ADD PLANET FUNCTION FOREVER
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.waitForDuration(3.0),
                SKAction.runBlock(addAlien)
                
                ])
            ))
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(3.0, withRange: 3.0)
                ])
            ))
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addBlackhole),
                SKAction.waitForDuration(3.0, withRange: 5.0)
                ])
            ))
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.waitForDuration(7.0, withRange: 5.0),
                SKAction.runBlock(addPlanet)
                ])
            ))
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.waitForDuration(20.0, withRange: 5.0),
                SKAction.runBlock(addWormhole)
                ])
            ))
    }
    
    ////////////////////////
    // START OF FUNCTIONS //
    ////////////////////////
    
    // FUNCTION THAT ADDS BACKGROUND TO SCENE
    func addBGToScene(){
        //bg.size.height = self.size.height
        //bg.size.width = self.size.width
        //addChild(bg)
        self.backgroundColor = SKColor.blackColor()
    }
    
    // FUNCTION THAT SETS UP END OF SCENE PERAMS
    func setupEndOfScreens(){
        endOfScreenLeft = (self.size.width) / 2 * CGFloat(-1)
        endOfScreenRight = self.size.width / 2 + 30
    }
    
    // FUNCTION THAT SETS UP SKY PERAMS
    func addSkyToScene(){
        sky.size = CGSize(width: self.size.width*2.0, height: 1)
        sky.position = CGPoint(x: -self.size.width*0.4, y: self.size.height*0.55)
        sky.physicsBody = SKPhysicsBody(rectangleOfSize: sky.size)
        sky.physicsBody?.dynamic = false
        sky.physicsBody?.restitution = 1.0
        sky.physicsBody?.categoryBitMask = ColliderType.Ground.rawValue
        sky.physicsBody?.collisionBitMask = ColliderType.Player.rawValue | ColliderType.PlayerWithStarPower.rawValue
        sky.physicsBody?.contactTestBitMask = ColliderType.None.rawValue
        self.addChild(sky)
    }
    
    // FUNCTION THAT SETS UP GROUND PERAMS
    func addGroundToScene(){
        ground.size = CGSize(width: self.size.width*2.0, height: 1)
        ground.position = CGPoint(x: -self.size.width*0.4, y: -self.size.height*0.55)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.restitution = 1.0
        ground.physicsBody?.categoryBitMask = ColliderType.Ground.rawValue
        ground.physicsBody?.collisionBitMask = ColliderType.Player.rawValue | ColliderType.PlayerWithStarPower.rawValue
        ground.physicsBody?.contactTestBitMask = ColliderType.None.rawValue
        self.addChild(ground)
    }
    
    // SETS UP UP FUNCTION TO ADD LEFT SIDE OF SCREEN
    func addLeftSideOfScene(){
        leftSideOfScene.size = CGSize(width: 1, height: self.size.height*2)
        leftSideOfScene.position = CGPoint(x: -self.size.width*0.52, y: -self.size.height*0.45)
        leftSideOfScene.physicsBody = SKPhysicsBody(rectangleOfSize: leftSideOfScene.size)
        leftSideOfScene.physicsBody?.dynamic = false
        leftSideOfScene.physicsBody?.restitution = 1.0
        leftSideOfScene.physicsBody?.categoryBitMask = ColliderType.LeftSideEdge.rawValue
        leftSideOfScene.physicsBody?.collisionBitMask = ColliderType.None.rawValue
        leftSideOfScene.physicsBody?.contactTestBitMask = ColliderType.Player.rawValue | ColliderType.PlayerWithStarPower.rawValue
        self.addChild(leftSideOfScene)
    }
    
    // SETS UP FUNCTION TO ADD RIGHT SIDE OF SCREEN
    func addRightSideOfScene(){
        rightSideOfScene.size = CGSize(width: 1, height: self.size.height*2)
        rightSideOfScene.position = CGPoint(x: self.size.width*0.55, y: -self.size.height*0.45)
        rightSideOfScene.physicsBody = SKPhysicsBody(rectangleOfSize: rightSideOfScene.size)
        rightSideOfScene.physicsBody?.dynamic = false
        rightSideOfScene.physicsBody?.restitution = 1.0
        rightSideOfScene.physicsBody?.categoryBitMask = ColliderType.RightSideEdge.rawValue
        rightSideOfScene.physicsBody?.collisionBitMask = ColliderType.Player.rawValue | ColliderType.PlayerWithStarPower.rawValue
        rightSideOfScene.physicsBody?.contactTestBitMask = ColliderType.None.rawValue
        self.addChild(rightSideOfScene)
    }
    
    // FUNCTION THAT SETS UPS PLAYER PERAMS
    func addPlayerToScene(){
        player.position = CGPoint(x: -self.size.width*0.3, y: 0)
        player.size = (CGSize(width: 45, height: 45))
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.dynamic = true
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.categoryBitMask = ColliderType.Player.rawValue
        player.physicsBody?.collisionBitMask = ColliderType.Ground.rawValue | ColliderType.RightSideEdge.rawValue
        player.physicsBody?.contactTestBitMask = ColliderType.Monster.rawValue | ColliderType.LeftSideEdge.rawValue | ColliderType.Wormhole.rawValue | ColliderType.Alien.rawValue
        player.physicsBody?.usesPreciseCollisionDetection = true
        addChild(player)
        
    }
    
    // FUNCTION THAT SETS UP SCORE LABEL
    func addScoreLabel(){
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.position = CGPoint(x: self.size.width*0.4, y: -self.size.height*0.45)
        timer = NSTimer.scheduledTimerWithTimeInterval(0.004, target:self, selector: Selector("updateScoreTimer"), userInfo: nil, repeats:true)
        scoreLabel.text = String("Score: \(counter)")
        addChild(scoreLabel)
    }
    
    // FUNCTION THAT SETS UP ALIEN LABEL
    func addAlienCounterLabel(){
        alienCounterLabel.fontSize = 18
        alienCounterLabel.fontColor = SKColor.whiteColor()
        alienCounterLabel.position = CGPoint(x: -self.size.width*0.35, y: -self.size.height*0.45)
        alienCounterLabel.text = String("Saucers Collected: \(alienCollectorCounter)")
        addChild(alienCounterLabel)
    }
    
    
    // FUNCTION THAT UPDATES SCORE VAR; IT IS CALLED WITH NSTIMER IN ADD SCORE LABEL FUNCTION
    func updateScoreTimer(){
        scoreLabel.text = String("Score: \(counter++)")
    }
    
    // SETS UP RANDOM FLOAT FUNCTIONS
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    // SETS UP FUNCTION TO ADD MONSTER (SUNS) TO THE SCENE
    func addMonster() {
        var sun = SKSpriteNode(imageNamed: "sun")
        var sunOne = SKSpriteNode(imageNamed: "sun_one")
        var sunTwo = SKSpriteNode(imageNamed: "sun_two")
        var sunThree = SKSpriteNode(imageNamed: "sun_three")
        var monsterArray = [sun, sunOne, sunTwo, sunThree]
        var randomMonster = monsterArray.randomArrayPick()
        var randomInt = Int(arc4random_uniform(10))
        
        // DETERMINES PHYSICS BODIES
        randomMonster.physicsBody = SKPhysicsBody(circleOfRadius: randomMonster.size.width/2)
        randomMonster.physicsBody?.dynamic = true
        randomMonster.physicsBody?.affectedByGravity = false
        randomMonster.physicsBody?.categoryBitMask = ColliderType.Monster.rawValue
        randomMonster.physicsBody?.contactTestBitMask = ColliderType.Player.rawValue | ColliderType.Projectile.rawValue | ColliderType.PlayerWithStarPower.rawValue
        randomMonster.physicsBody?.collisionBitMask = ColliderType.None.rawValue | ColliderType.Projectile.rawValue
        randomMonster.physicsBody?.usesPreciseCollisionDetection = true
        randomMonster.physicsBody?.linearDamping = 3
        randomMonster.physicsBody?.fieldBitMask = 0
        randomMonster.physicsBody?.mass = 2
        
        // DETERMINES WHERE MOSNTER SPAWNS RANDOMLY
        let actualY = random(min: -self.size.height*0.45, max:self.size.height*0.45)
        // SETS UP SIZE OF MONSTER WITH RANDOM FLUCUTATIONS AND POSITION
        randomMonster.size = CGSize(width: 45 + randomInt, height: 45 + randomInt)
        randomMonster.position = CGPoint(x: self.size.width*0.55, y: actualY)
        
        // ADDS MONSTER TO SCENE
        addChild(randomMonster)
        // DETERMINES SPEED OF MONSTER TRAVELING ACROSS SCREEN
        let actualDuration = random(min: CGFloat(1.0), max: CGFloat(4.0))
        
        // STARTS ACTION
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width*0.55, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        randomMonster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        if (explodeStars == true){
            explosion2(actionMove, actionMoveDone: actionMoveDone, pos: randomMonster.position)
        }
        }
    
    // SETS UP FUNCTION TO ADD PLANET TO SCENE
    func addPlanet(){
        var jupiter = SKSpriteNode(imageNamed: "jupiter")
        var pluto = SKSpriteNode(imageNamed: "pluto")
        var planetArray = [jupiter, pluto]
        var randomPlanet = planetArray.randomArrayPick()
        var randomInt = Int(arc4random_uniform(30))
        randomPlanet.physicsBody = SKPhysicsBody(circleOfRadius: randomPlanet.size.width/2)
        randomPlanet.physicsBody?.dynamic = true
        randomPlanet.physicsBody?.affectedByGravity = false
        randomPlanet.physicsBody?.restitution = 7
        randomPlanet.physicsBody?.categoryBitMask = ColliderType.Planet.rawValue
        randomPlanet.physicsBody?.contactTestBitMask = ColliderType.None.rawValue | ColliderType.Projectile.rawValue
        randomPlanet.physicsBody?.collisionBitMask = ColliderType.Player.rawValue | ColliderType.Projectile.rawValue | ColliderType.PlayerWithStarPower.rawValue
        randomPlanet.physicsBody?.usesPreciseCollisionDetection = true
        randomPlanet.physicsBody?.fieldBitMask = 0
        randomPlanet.physicsBody?.linearDamping = 3
        randomPlanet.physicsBody?.mass = 2
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: -self.size.height*0.45, max:self.size.height*0.45)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        randomPlanet.size = CGSize(width: 45 + randomInt, height: 45 + randomInt)
        randomPlanet.position = CGPoint(x: self.size.width*0.55, y: actualY)
        
        // Add the monster to the scene
        addChild(randomPlanet)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(0.7), max: CGFloat(3.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width*0.55, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        randomPlanet.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    // FUNCTION THAT SETS UP BLACKHOLE
    func addBlackhole(){
        let blackHole = SKSpriteNode(imageNamed: "blackhole")
        blackHole.physicsBody = SKPhysicsBody(circleOfRadius: blackHole.size.width/2)
        blackHole.physicsBody?.dynamic = false
        blackHole.physicsBody?.affectedByGravity = false
        blackHole.physicsBody?.collisionBitMask = ColliderType.Monster.rawValue | ColliderType.Planet.rawValue | ColliderType.Wormhole.rawValue
        blackHole.physicsBody?.categoryBitMask = ColliderType.Blackhole.rawValue
        blackHole.physicsBody?.contactTestBitMask = ColliderType.Monster.rawValue | ColliderType.Planet.rawValue | ColliderType.Wormhole.rawValue | ColliderType.Player.rawValue | ColliderType.PlayerWithStarPower.rawValue
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: -self.size.height*0.45, max:self.size.height*0.45)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        blackHole.size = CGSize(width: 25, height: 25)
        blackHole.position = CGPoint(x: self.size.width*0.55, y: actualY)
        // Add the monster to the scene
        addChild(blackHole)
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(5.0), max: CGFloat(10.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width*0.55, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        blackHole.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        var fieldNode = SKFieldNode.radialGravityField();
        fieldNode.falloff = 0.2;
        fieldNode.strength = 1.2;
        fieldNode.animationSpeed = 0.2;
        fieldNode.position = CGPoint(x: self.size.width*0.55, y: actualY)
        fieldNode.categoryBitMask = ColliderType.BlackHoleGravity.rawValue
        addChild(fieldNode)
        fieldNode.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    // FUNCTION THAT SETS UP ALIEN
    func addAlien(){
        var randomInt = Int(arc4random_uniform(30))
        alien.physicsBody = SKPhysicsBody(circleOfRadius: alien.size.width/2)
        alien.physicsBody?.dynamic = false
        alien.physicsBody?.affectedByGravity = false
        alien.physicsBody?.categoryBitMask = ColliderType.Alien.rawValue
        alien.physicsBody?.contactTestBitMask = ColliderType.Player.rawValue | ColliderType.PlayerWithStarPower.rawValue | ColliderType.PlayerWithStarPower.rawValue
        alien.physicsBody?.fieldBitMask = 0
        alien.name = "alienName"
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: -self.size.height*0.45, max:self.size.height*0.45)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        alien.size = CGSize(width: 25, height: 25)
        alien.position = CGPoint(x: self.size.width*0.55, y: actualY)
        
        // Add the monster to the scene
        alien.removeFromParent()
        addChild(alien)
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(3.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width*0.55, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        alien.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        alienParticles(actionMove, actionMoveDone: actionMoveDone, pos: alien.position)

    }
    
    // FUNCTION THAT SETS UP WORMHOME TO SCENE
    func addWormhole(){
        var wormhole = SKSpriteNode(imageNamed: "wormhole")
        var randomInt = Int(arc4random_uniform(30))
        wormhole.physicsBody = SKPhysicsBody(circleOfRadius: wormhole.size.width/2)
        wormhole.physicsBody?.dynamic = true
        wormhole.physicsBody?.affectedByGravity = false
        wormhole.physicsBody?.categoryBitMask = ColliderType.Wormhole.rawValue
        wormhole.physicsBody?.contactTestBitMask = ColliderType.Player.rawValue | ColliderType.Blackhole.rawValue | ColliderType.Projectile.rawValue | ColliderType.PlayerWithStarPower.rawValue
        wormhole.physicsBody?.collisionBitMask = ColliderType.None.rawValue | ColliderType.Projectile.rawValue
        wormhole.physicsBody?.fieldBitMask = 0
        wormhole.physicsBody?.usesPreciseCollisionDetection = true
        wormhole.physicsBody?.linearDamping = 3
        wormhole.physicsBody?.mass = 2
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: -self.size.height*0.45, max:self.size.height*0.45)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        wormhole.size = CGSize(width: 45 + randomInt, height: 45 + randomInt)
        wormhole.position = CGPoint(x: self.size.width*0.55, y: actualY)
        
        // Add the monster to the scene
        addChild(wormhole)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(0.7), max: CGFloat(3.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -self.size.width*0.55, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        wormhole.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    /////////////////////////////////////////////////
    // FUNCTION TO SETUP CONTACT BIT MASK SCENEROS //
    /////////////////////////////////////////////////
    func didBeginContact(contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask == ColliderType.Player.rawValue && contact.bodyB.categoryBitMask == ColliderType.Ground.rawValue || contact.bodyB.categoryBitMask == ColliderType.Player.rawValue && contact.bodyA.categoryBitMask == ColliderType.Ground.rawValue){
            println("you hit the bottom or top")
        }
        if (contact.bodyA.categoryBitMask == ColliderType.Player.rawValue && contact.bodyB.categoryBitMask == ColliderType.Monster.rawValue || contact.bodyB.categoryBitMask == ColliderType.Player.rawValue && contact.bodyA.categoryBitMask == ColliderType.Monster.rawValue){
            println("you hit a monster")
            playerDidCollideWithMonster()
        }
        
        if (contact.bodyA.categoryBitMask == ColliderType.Player.rawValue && contact.bodyB.categoryBitMask == ColliderType.LeftSideEdge.rawValue || contact.bodyB.categoryBitMask == ColliderType.Player.rawValue && contact.bodyA.categoryBitMask == ColliderType.LeftSideEdge.rawValue){
            println("you hit the left edge")
            playerDidCollideWithLeftSideOfScreen()
        }
        if (contact.bodyA.categoryBitMask == ColliderType.Player.rawValue && contact.bodyB.categoryBitMask == ColliderType.Planet.rawValue || contact.bodyB.categoryBitMask == ColliderType.Player.rawValue && contact.bodyA.categoryBitMask == ColliderType.Planet.rawValue){
            println("you hit a planet")
        }
        if (contact.bodyA.categoryBitMask == ColliderType.Player.rawValue && contact.bodyB.categoryBitMask == ColliderType.Wormhole.rawValue || contact.bodyB.categoryBitMask == ColliderType.Player.rawValue && contact.bodyA.categoryBitMask == ColliderType.Wormhole.rawValue){
            println("you hit a wormhole")
            playerDidCollideWithWormhole()
        }
        if (contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 10 || contact.bodyB.categoryBitMask == 1 && contact.bodyA.categoryBitMask == 10){
            println("you hit a blackhole")
            playerDidCollideWithBlackhole()
        }
        if (contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 7 || contact.bodyB.categoryBitMask == 1 && contact.bodyA.categoryBitMask == 7){
            println("you hit an alien")
            playerDidCollideWithAlien()
        }
        if (contact.bodyA.categoryBitMask == 15 && contact.bodyB.categoryBitMask == 2 || contact.bodyB.categoryBitMask == 15 && contact.bodyA.categoryBitMask == 2){
            println("you hit a monster with star power")
        }
        if (contact.bodyA.categoryBitMask == 15 && contact.bodyB.categoryBitMask == 4 || contact.bodyB.categoryBitMask == 15 && contact.bodyA.categoryBitMask == 4){
            println("you hit a wormhole with star power")
        }
        if (contact.bodyA.categoryBitMask == 15 && contact.bodyB.categoryBitMask == 5 || contact.bodyB.categoryBitMask == 15 && contact.bodyA.categoryBitMask == 5){
            println("you hit a sun with star power")
        }
        if (contact.bodyA.categoryBitMask == 15 && contact.bodyB.categoryBitMask == 6 || contact.bodyB.categoryBitMask == 15 && contact.bodyA.categoryBitMask == 6){
            println("you hit a planet with star power")
        }

    }
    

    func starPowerActive(){
        var starPowerLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
        var starPowerLabel1 = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
      player.physicsBody?.categoryBitMask = ColliderType.PlayerWithStarPower.rawValue
        snowEmitterNode.removeFromParent()
        fire(self.player.position)
        var starPowerTimer = NSTimer()
        starPowerTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target:self, selector: Selector("addStarPower"), userInfo: nil, repeats:false)
        var starRemoveParticles = NSTimer()
        isStarPowerOn = false
        starPowerLabel.fontSize = 18
        starPowerLabel.fontColor = SKColor.whiteColor()
        starPowerLabel.position = CGPoint(x: 0, y: 0)
        starPowerLabel.text = "You are traveling at the speed of light, you will bounce off all bodies."
        
        addChild(starPowerLabel)
        let fadeAction = SKAction.fadeAlphaTo(0, duration: 4.0)
        starPowerLabel.runAction(fadeAction)
        
        starPowerLabel1.fontSize = 18
        starPowerLabel1.fontColor = SKColor.whiteColor()
        starPowerLabel1.position = CGPoint(x: 0, y: -20)
        starPowerLabel1.text = "Enabled for 10 seconds"
        addChild(starPowerLabel1)
        let fadeAction1 = SKAction.fadeAlphaTo(0, duration: 4.0)
        starPowerLabel1.runAction(fadeAction1)
    }
    
    func addStarPower(){
        var starPowerLabel2 = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
        
        starPowerLabel2.fontSize = 20
        starPowerLabel2.fontColor = SKColor.whiteColor()
        starPowerLabel2.position = CGPoint(x: 0, y: 0)
        starPowerLabel2.text = "Speed normalized."
        
        addChild(starPowerLabel2)
        let fadeAction = SKAction.fadeAlphaTo(0, duration: 2.0)
        starPowerLabel2.runAction(fadeAction)
        player.physicsBody?.categoryBitMask = ColliderType.Player.rawValue
        fireEmitterNode.removeFromParent()
        addChild(snowEmitterNode)
        isStarPowerOn = false
        explodeStars = false
    }
    
    // FUNCTION THAT STARTS WHEN PLAYER COLLIDES WITH ALIEN
    func playerDidCollideWithAlien(){
        alien.removeFromParent()
        alienCollectorCounter++
        alienCounterLabel.text = String("Saucers Collected: \(alienCollectorCounter)")
        
        if (alienCollectorCounter == 1){
            isFullControlEnabled = true
            fullControlLabel.fontSize = 20
            fullControlLabel.fontColor = SKColor.whiteColor()
            fullControlLabel.position = CGPoint(x: 0, y: 0)
            fullControlLabel.text = "You collected 5 alien saucers and now have the technology to"
            addChild(fullControlLabel)
            let fadeAction = SKAction.fadeAlphaTo(0, duration: 4.0)
            fullControlLabel.runAction(fadeAction)
            
            fullControlLabel1.fontSize = 20
            fullControlLabel1.fontColor = SKColor.whiteColor()
            fullControlLabel1.position = CGPoint(x: 0, y: -20)
            fullControlLabel1.text = "fully control Earth. Swipe to move Earth in all directions."
            addChild(fullControlLabel1)
            let fadeAction1 = SKAction.fadeAlphaTo(0, duration: 4.0)
            fullControlLabel1.runAction(fadeAction1)
            
            allowFullControls()
        }
        if (alienCollectorCounter == 2){
            isStarPowerOn = true
            var starPowerLabel3 = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
            var starPowerLabel4 = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
            starPowerLabel3.text = "You have recieved the ability to travel at quantum speeds. You may pass through all bodies."
            starPowerLabel4.text = "Double tap to enable powers for 10 seconds."
            starPowerLabel3.fontSize = 18
            starPowerLabel3.fontColor = SKColor.whiteColor()
            starPowerLabel3.position = CGPoint(x: 0, y: 0)
            addChild(starPowerLabel3)
            let fadeAction = SKAction.fadeAlphaTo(0, duration: 4.0)
            starPowerLabel3.runAction(fadeAction)
            
            starPowerLabel4.fontSize = 18
            starPowerLabel4.fontColor = SKColor.whiteColor()
            starPowerLabel4.position = CGPoint(x: 0, y: -20)
            addChild(starPowerLabel4)
            let fadeAction1 = SKAction.fadeAlphaTo(0, duration: 4.0)
            starPowerLabel4.runAction(fadeAction1)
        }
        
        if (alienCollectorCounter == 3){
            explosion(self.player.position)
            player.removeFromParent()
            
        }
        
        
        var alienTimer = NSTimer()
        alienTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target:self, selector: Selector("addAlienChild"), userInfo: nil, repeats:false)
    }
    func addAlienChild(){
        alien.removeFromParent()
        addChild(alien)
        
    }
    
    // FUNCTIONS TO FOR BONUS'S
    func allowFullControls(){
        //////////////////////////////
        // SETS UP CONTROL GESTURES //
        //////////////////////////////
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedRight:"))
        swipeRight.direction = .Right
        view?.addGestureRecognizer(swipeRight)
        
        
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedLeft:"))
        swipeLeft.direction = .Left
        view?.addGestureRecognizer(swipeLeft)
        
        
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedUp:"))
        swipeUp.direction = .Up
        view?.addGestureRecognizer(swipeUp)
        
        
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedDown:"))
        swipeDown.direction = .Down
        view?.addGestureRecognizer(swipeDown)
        /////////////////////////////
        // END OF CONTROL GESTURES //
        ////////////////////////////
    }
    
    // FUNCTIONS THAT TAKE EFFECT FOR SWIPE GESTURES
    func swipedRight(sender:UISwipeGestureRecognizer){
        println("swiped right")
        player.physicsBody?.velocity = CGVectorMake(0,0)
        player.physicsBody?.applyImpulse(CGVectorMake(13, 0))
    }
    
    func swipedLeft(sender:UISwipeGestureRecognizer){
        println("swiped left")
        player.physicsBody?.velocity = CGVectorMake(0,0)
        player.physicsBody?.applyImpulse(CGVectorMake(-13, 0))
    }
    
    func swipedUp(sender:UISwipeGestureRecognizer){
        println("swiped up")
        player.physicsBody?.velocity = CGVectorMake(0,0)
        player.physicsBody?.applyImpulse(CGVectorMake(0, 13))
    }
    
    func swipedDown(sender:UISwipeGestureRecognizer){
        println("swiped down")
        player.physicsBody?.velocity = CGVectorMake(0,0)
        player.physicsBody?.applyImpulse(CGVectorMake(0, -13))
    }
    
    
    // FUNCTION THAT STARTS WHEN PLAYER COLLIDES WITH A MONSTER
    func playerDidCollideWithMonster(){
        explosion(self.player.position)
        player.removeFromParent()
        gameOver = true
        player.physicsBody?.dynamic = false
        timer.invalidate()
        runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.runBlock() {
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let gameOverScene = GameOverScene(size: self.size, won: false, counter: self.counter)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
            ]))
    }
    
    // FUNCTIONS TO SETUP IF PLAYER COLLIDED WITH WORMHOLE
    func playerDidCollideWithWormhole(){
        var wormHoleLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-SemiBold")
        isControlNormal = false
        wormHoleLabel.fontSize = 26
        wormHoleLabel.fontColor = SKColor.whiteColor()
        wormHoleLabel.position = CGPoint(x: 0, y: 0)
        wormHoleLabel.text = "Wormhole Was Hit! Controls Are Reversed For 10 Seconds."
        addChild(wormHoleLabel)
        let fadeAction = SKAction.fadeAlphaTo(0, duration: 3.0)
        wormHoleLabel.runAction(fadeAction)
        
        wormholeTimer = NSTimer.scheduledTimerWithTimeInterval(10, target:self, selector: Selector("wormholeFunc"), userInfo: nil, repeats:false)
    }
    func wormholeFunc(){
        isControlNormal = true
    }
    
    // FUNCTION THAT STARTS WHEN PLAYER COLLIDES WITH BLACKHOLE
    func playerDidCollideWithBlackhole(){
        magic(self.player.position)
        player.removeFromParent()
        runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.runBlock() {
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let gameOverScene = GameOverScene(size: self.size, won: false, counter: self.counter)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
            ]))
    }
    
    // FUNCTION THAT STARTS WHEN PLAYER COLLIDES WITH THE LEFT SIDE OF SCREEN
    func playerDidCollideWithLeftSideOfScreen(){
        explosion(self.player.position)
        player.removeFromParent()
        gameOver = true
        player.physicsBody?.dynamic = false
        timer.invalidate()
        runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.runBlock() {
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let gameOverScene = GameOverScene(size: self.size, won: false, counter: self.counter)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
            ]))
    }
    ///////////////////////
    // EMITTER FUNCTIONS //
    ///////////////////////
    func explosion(pos: CGPoint) {
        var emitterNode = SKEmitterNode(fileNamed: "HitParticles.sks")
        emitterNode.particlePosition = pos
        self.addChild(emitterNode)
        // Don't forget to remove the emitter node afte r the explosion
        self.runAction(SKAction.waitForDuration(2), completion: { emitterNode.removeFromParent() })
    }
    func explosion2(actionMove: SKAction, actionMoveDone: SKAction, pos: CGPoint) {
        var emitterNode = SKEmitterNode(fileNamed: "HitParticles.sks")
        self.addChild(emitterNode)
        emitterNode.position = pos
        emitterNode.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        self.runAction(SKAction.waitForDuration(10), completion: { emitterNode.removeFromParent() })
    }
    func magic(pos: CGPoint){
        var magicEmitterNode = SKEmitterNode(fileNamed: "MagicParticle.sks")
        magicEmitterNode.particlePosition = pos
        self.addChild(magicEmitterNode)
    }
    func fire(pos: CGPoint){
        fireEmitterNode.particlePosition = pos
        self.addChild(fireEmitterNode)

    }
    func alienParticles(actionMove: SKAction, actionMoveDone: SKAction, pos: CGPoint){
        var emitterNode = SKEmitterNode(fileNamed: "alienParticles.sks")
        self.addChild(emitterNode)
        emitterNode.position = pos
        emitterNode.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        self.runAction(SKAction.waitForDuration(10), completion: { emitterNode.removeFromParent() })
        
    }
    

    
}