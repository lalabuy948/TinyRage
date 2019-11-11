//
//  GameScene.swift
//  TinyRage WatchKit Extension
//
//  Created by Daniil Popov on 11/9/19.
//  Copyright © 2019 Daniil Popov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode();
    var pipeUpTexture = SKTexture();
    var pipeDownTexture = SKTexture();
    var pipesMoveAndThenRemove = SKAction();
    
    // score
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)";
        }
    }
    
    override func sceneDidLoad() -> Void {
        
        // Physics
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.5);
        
        // Bird texture
        let birdTexture = SKTexture(imageNamed: "birdPicture");
        birdTexture.filteringMode = SKTextureFilteringMode.nearest;
        // Bird node
        bird = SKSpriteNode(texture: birdTexture);
        bird.setScale(0.1);
        bird.position = CGPoint(x: -self.frame.size.width * 0.15, y: self.frame.size.height * 0.1);
        // Bird physics
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2.0);
        bird.physicsBody?.isDynamic = true;
        bird.physicsBody?.allowsRotation = false;
        // Add bird
        self.addChild(bird);
        
        // Ground texture
        let groundTexture = SKTexture(imageNamed: "groundPictureLight");
        let ground        = SKSpriteNode(texture: groundTexture);
        ground.setScale(3.0);
        ground.position = CGPoint(x: 0, y: -ground.size.height * 2.5);
        // Ground physics
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: ground.size.height * 0.7));
        ground.physicsBody?.isDynamic = false;
        // Add ground
        self.addChild(ground);
        
        // Pipes textures
        pipeUpTexture   = SKTexture(imageNamed: "wallPictureLight");
        pipeDownTexture = SKTexture(imageNamed: "wallPictureLight");
        
        let distanceToMove = CGFloat(self.frame.size.width + 2 * pipeUpTexture.size().width);
        let movePipes      = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(0.01 * distanceToMove));
        let removePipes    = SKAction.removeFromParent();
        
        pipesMoveAndThenRemove = SKAction.sequence([movePipes, removePipes]);
        
        let spawn = SKAction.run(self.spawnPipes);
        let delay = SKAction.wait(forDuration: 2.0);
        let spawnThenDelay = SKAction.sequence([spawn, delay]);
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay);
        self.run(spawnThenDelayForever);
    }
    
    func spawnPipes() -> Void {
        
        let pipesGap = 1.0;
        
        let pipePair = SKNode();
        pipePair.position = CGPoint(x: self.frame.size.width / 2 , y: 0);
        
        let heigth = UInt32(self.frame.size.height / 4);
        let y = arc4random() % heigth + heigth;
        
        let pipeUp = SKSpriteNode(texture: pipeUpTexture);
        pipeUp.setScale(1.5);
        pipeUp.position = CGPoint(x: 0.0, y: (CGFloat(y) + pipeUp.size.height + CGFloat(pipesGap)) / 2);
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipeUp.size);
        pipeUp.physicsBody?.isDynamic = false;
        pipePair.addChild(pipeUp);
        
        let pipeDown = SKSpriteNode(texture: pipeDownTexture);
        pipeDown.setScale(1.5);
        pipeDown.position = CGPoint(x: 0.0, y: -(CGFloat(y) + pipeDown.size.height + CGFloat(pipesGap)) / 2);
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeDown.size);
        pipeDown.physicsBody?.isDynamic = false;
        pipePair.addChild(pipeDown);
        
        pipePair.run(pipesMoveAndThenRemove);
        self.addChild(pipePair);
        
    }
    
    func applyBirdImpulse() -> Void {
        bird.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0);
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10.0));
    }
    
    override func update(_ currentTime: TimeInterval) -> Void {
        // Called before each frame is rendered
    }

}
