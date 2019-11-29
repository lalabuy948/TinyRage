//
//  GameScene.swift
//  TinyRage WatchKit Extension
//
//  Created by Daniil Popov on 11/9/19.
//  Copyright © 2019 Daniil Popov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird                   = SKSpriteNode();
    var pipeUpTexture          = SKTexture();
    var pipeDownTexture        = SKTexture();
    var pipesMoveAndThenRemove = SKAction();
    var spawnThenDelayForever  = SKAction();
    
    let birdCategory: UInt32   = 0x1 << 1;
    let wallCategory: UInt32   = 0x1 << 1;
    
    var gameOverLabel:SKLabelNode!
    // score
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)";
            
            gameOverLabel.text = "Game over :("
        }
    }
    
    @objc override func sceneDidLoad() -> Void {
        
        self.gameOverLabel?.removeFromParent();
        
        self.initGameOverPopup()
        
        // Init score
        self.initScore()
        
        // Init bird
        self.initBird();
        
        // Init ground
        self.initGround();
        
        // Pipes textures
        pipeUpTexture   = SKTexture(imageNamed: "wallPictureDark");
        pipeDownTexture = SKTexture(imageNamed: "wallPictureDark");
        
        let distanceToMove = CGFloat(self.frame.size.width + 2 * pipeUpTexture.size().width);
        let movePipes      = SKAction.moveBy(x: -distanceToMove,
                                             y: 0.0,
                                             duration: TimeInterval(0.01 * distanceToMove));
        let removePipes    = SKAction.removeFromParent();
        
        pipesMoveAndThenRemove = SKAction.sequence([movePipes, removePipes]);
        
        let spawn = SKAction.run(self.spawnPipes);
        let delay = SKAction.wait(forDuration: 2.0);
        let spawnThenDelay         = SKAction.sequence([spawn, delay]);
        self.spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay);
        
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startGamePlay), userInfo: nil, repeats: false)
    }
    
    @objc func startGamePlay() -> Void {
        // Physics
        self.physicsWorld.gravity         = CGVector(dx: 0.0, dy: -5.5);
        self.physicsWorld.contactDelegate = self
        bird.physicsBody?.isDynamic       = true;

        // Start spawing pipes
        self.run(spawnThenDelayForever);
    }

    func initScore() -> Void {
        scoreLabel           = SKLabelNode(fontNamed: "Helvetica-Bold");
        scoreLabel.fontSize  = 26;
        scoreLabel.position  = CGPoint(x: -self.frame.size.width / 2 + 75,
                                       y: self.frame.size.height / 2 - 45);
        scoreLabel.zPosition = 1;
        score = 0;
        self.addChild(scoreLabel);
    }
    
    func initGameOverPopup() -> Void {
        gameOverLabel           = SKLabelNode(fontNamed: "Helvetica-Bold");
        gameOverLabel.name      = "gameOverLabel";
        gameOverLabel.isHidden  = true;
        gameOverLabel.fontSize  = 30;
        gameOverLabel.position  = CGPoint(x: 0, y: 0);
        gameOverLabel.zPosition = 2;
        
        self.addChild(gameOverLabel);
    }
    
    // MARK: initBird
    func initBird() -> Void {
        // Bird texture
        let birdTexture = SKTexture(imageNamed: "birdPicture");
        birdTexture.filteringMode = SKTextureFilteringMode.nearest;
        // Bird node
        bird = SKSpriteNode(texture: birdTexture);
        bird.name = "birdNode";
        bird.setScale(0.1);
        bird.position = CGPoint(x: -self.frame.size.width * 0.15,
                                y: self.frame.size.height * 0.1);
        // Bird physics
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2);
        
        bird.physicsBody?.isDynamic      = false;
        bird.physicsBody?.allowsRotation = false;
        
        bird.physicsBody?.categoryBitMask    = birdCategory;
        bird.physicsBody?.contactTestBitMask = wallCategory;
        bird.physicsBody?.collisionBitMask   = wallCategory;

        // Add bird
        self.addChild(bird);
    }
    
    // MARK: initGround
    func initGround() -> Void {
        // Ground texture
        let groundTexture = SKTexture(imageNamed: "groundPictureLight");
        let ground        = SKSpriteNode(texture: groundTexture);
        ground.name       = "groundNode";
        ground.setScale(3.0);
        ground.position = CGPoint(x: 0, y: -ground.size.height * 2.7);
        // Ground physics
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width,
                                                               height: ground.size.height));
        ground.physicsBody?.isDynamic = false;

        // Add ground
        self.addChild(ground);
    }
    
    // MARK: spawnPipes
    func spawnPipes() -> Void {
        
        let pipesGap: CGFloat  = 1.0;
        let wallScale: CGFloat = 1;
        
        let pipePair = SKNode();
        pipePair.position = CGPoint(x: self.frame.size.width / 2 , y: 0);
        
        let heigth = UInt32(self.frame.size.height / 4);
        let y = arc4random() % heigth + heigth;
        
        let pipeUp = SKSpriteNode(texture: pipeUpTexture);
        pipeUp.setScale(wallScale);
        pipeUp.position = CGPoint(x: 0.0,
                                  y: (CGFloat(y) + pipeUp.size.height + pipesGap) / 2);
        
        pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipeUp.size);
        pipeUp.physicsBody?.isDynamic = false;
        
        pipeUp.physicsBody?.categoryBitMask    = wallCategory;
        pipeUp.physicsBody?.contactTestBitMask = birdCategory;
        pipeUp.physicsBody?.collisionBitMask   = birdCategory;

        pipePair.addChild(pipeUp);
        
        let pipeDown = SKSpriteNode(texture: pipeDownTexture);
        pipeDown.setScale(wallScale);
        pipeDown.position = CGPoint(x: 0.0,
                                    y: -(CGFloat(y) + pipeDown.size.height + pipesGap) / 2);
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeDown.size);
        pipeDown.physicsBody?.isDynamic = false;

        pipeDown.physicsBody?.categoryBitMask    = wallCategory;
        pipeDown.physicsBody?.contactTestBitMask = birdCategory;
        pipeDown.physicsBody?.collisionBitMask   = birdCategory;
        
        pipePair.addChild(pipeDown);
        
        pipePair.run(pipesMoveAndThenRemove);
        
        self.addChild(pipePair);

    }
    
    // MARK: applyBirdImpulse
    func applyBirdImpulse() -> Void {
        
        if self.scene?.isPaused == true {
            self.scene?.isPaused = false;
        };
        
        bird.physicsBody?.velocity = CGVector(dx: 0.0,
                                              dy: 0.0);
        bird.physicsBody?.applyImpulse(CGVector(dx: 0,
                                                dy: 10.0));
    }
    
    // MARK: collisions
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody;
        var secondBody:SKPhysicsBody;
        
         if contact.bodyA.categoryBitMask < contact.bodyB.collisionBitMask {
            firstBody  = contact.bodyA;
            secondBody = contact.bodyB;
         } else {
            firstBody  = contact.bodyB;
            secondBody = contact.bodyA;
        }
        
        if  (firstBody.collisionBitMask == wallCategory) || (secondBody.collisionBitMask == birdCategory) {
            self.restartGame();
        }
    }
    
    func restartGame() {
        self.removeAllActions();
        self.gameOverLabel.isHidden = false;
        
        for node in self.children {
            if node.name != "background" && node.name != "gameOverLabel" {
                node.removeFromParent();
            }
        }
        
        _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(sceneDidLoad), userInfo: nil, repeats: false)
        
        self.bird.removeFromParent();
    }
    
    override func update(_ currentTime: TimeInterval) -> Void {
        // Called before each frame is rendered
    }

}
