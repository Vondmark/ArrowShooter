//
//  GameScene.swift
//  ArrowShooter
//
//  Created by Mark on 9/12/19.
//  Copyright © 2019 Mark. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var target:SKSpriteNode!
    var restartButtonNode:SKSpriteNode!
    var player:SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score:Int = 0{
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    var gameTimer:Timer!
    var targets = "target"
    
    let centerTargetCategory:UInt32 = 0x1 << 2
    let targetCategory:UInt32       = 0x1 << 1
    let arrowCategory:UInt32        = 0x1 << 0
    
    
    override func didMove(to view: SKView) {
        
        restartButtonNode = (self.childNode(withName: "restartButton") as! SKSpriteNode)
        restartButtonNode.zPosition = 1
        restartButtonNode.isHidden = true
        let backGround = SKSpriteNode(imageNamed: "background")
        backGround.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        backGround.position = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        self.addChild(backGround)
        backGround.zPosition = -1
        player = SKSpriteNode(imageNamed: "arrow")
        player.position = CGPoint(x: UIScreen.main.bounds.midX-86, y: UIScreen.main.bounds.minY+85)
        
        
        
        self.addChild(player)
        
        
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName     = "GillSans-Bold"
        scoreLabel.fontSize     = 30
        scoreLabel.fontColor    = UIColor.yellow
        scoreLabel.position     = CGPoint(x: UIScreen.main.bounds.minX+90, y: UIScreen.main.bounds.maxY-150)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(addTarget), userInfo: nil, repeats: true)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var targetBody:SKPhysicsBody
        var arrowBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            arrowBody    = contact.bodyA
            targetBody    = contact.bodyB
        } else {
            arrowBody    = contact.bodyB
            targetBody   = contact.bodyA
        }
        
        if (targetBody.categoryBitMask & targetCategory) != 0 && (arrowBody.categoryBitMask & arrowCategory) != 0 {
            collisionElements(arrowNode: arrowBody.node as! SKSpriteNode, targetNode: targetBody.node as! SKSpriteNode)
        }
        
        
    }
    

    
    func collisionElements (arrowNode:SKSpriteNode, targetNode: SKSpriteNode) {
        let hit = SKEmitterNode(fileNamed: "hit")
        let arrowHit = SKEmitterNode(fileNamed: "arrowHit")
        let plusOneScore = SKEmitterNode(fileNamed: "plusScore")
        
        if arrowNode.position.x.isEqual(to: targetNode.position.x/2){
            print("+2")
            print("\(targetNode.position.x)")
        }
        
        
        hit?.position = targetNode.position
        arrowHit?.position = arrowNode.position
        plusOneScore?.position = CGPoint(x: arrowNode.position.x + 50, y: arrowNode.position.y)
        
        self.addChild(hit!)
        self.addChild(arrowHit!)
        self.addChild(plusOneScore!)
        
        
        arrowNode.removeFromParent()
        targetNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 0.7)) {
            hit?.removeFromParent()
            arrowHit?.removeFromParent()
            plusOneScore?.removeFromParent()
            
        }
    
        score += 1
    }
    
    //func spawn target on view
    @objc func addTarget () {
        print("NewTarget")
        target  = SKSpriteNode(imageNamed: targets)
        let randomPosition = GKRandomDistribution(lowestValue: Int(UIScreen.main.bounds.minY+200), highestValue: Int(UIScreen.main.bounds.maxX-470))
        let position = CGFloat(randomPosition.nextInt())
        target.position = CGPoint(x: UIScreen.main.bounds.minX-400, y: position)
    
        target.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: target.size.width/2, height:       target.size.height/4))
        target.physicsBody?.isDynamic = true
    
        target.physicsBody?.categoryBitMask = targetCategory
        target.physicsBody?.contactTestBitMask = arrowCategory
        target.physicsBody?.collisionBitMask = 0
    
        self.addChild(target)
    
        //speed target
        let animationDuration:TimeInterval = 20
    
    
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: UIScreen.main.bounds.maxX+400, y: position), duration:       animationDuration))
        
        actions.append(SKAction.removeFromParent())
        
    
        target.run(SKAction.sequence(actions))
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded")
        archery()
        
        let secondSide = CGPoint(x: UIScreen.main.bounds.midX-43, y: UIScreen.main.bounds.minY+85)
        let firstSide = CGPoint(x: UIScreen.main.bounds.midX-129, y: UIScreen.main.bounds.minY+85)
        
        let moveArrow = SKAction.move(to: secondSide, duration: 1.5)
        let moveArrowBack = SKAction.move(to: firstSide, duration: 2)
        
        let moveToSequence = SKAction.sequence([moveArrow,moveArrowBack])
        
        player.run(moveToSequence)
        
//        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "restartButton"{
                didMove(to: self.view!)
            }
        }
    }
    
    func archery() {
        let arrow = SKSpriteNode(imageNamed: "arrow")
        arrow.position = player.position
        
        arrow.physicsBody = SKPhysicsBody(rectangleOf: arrow.size)
        arrow.physicsBody?.isDynamic = true
        
        arrow.physicsBody?.categoryBitMask          = arrowCategory
        arrow.physicsBody?.contactTestBitMask       = targetCategory
        arrow.physicsBody?.collisionBitMask         = 0
        arrow.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(arrow)
        //speed arrow
        let animationDuration:TimeInterval = 1
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: 800), duration: animationDuration))
        actions.append(SKAction.removeFromParent())
        
        arrow.run(SKAction.sequence(actions))
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
