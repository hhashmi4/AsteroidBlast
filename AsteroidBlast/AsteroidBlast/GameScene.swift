import SpriteKit

// MARK: - Physics categories (bit masks)
struct PhysicsCategory {
    static let none:    UInt32 = 0
    static let player:  UInt32 = 1 << 0
    static let asteroid:UInt32 = 1 << 1
    static let bullet:  UInt32 = 1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Time tracking
    private var lastUpdateTime: TimeInterval = 0

    // MARK: - Player
    private var player: SKSpriteNode!

    // MARK: - Asteroid spawn
    private var timeSinceLastAsteroid: TimeInterval = 0
    private let asteroidSpawnInterval: TimeInterval = 1.2  // seconds

    // MARK: - Score / Lives
    private var score: Int = 0
    private var lives: Int = 3

    private var scoreLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!

    // MARK: - Scene setup
    override func didMove(to view: SKView) {
        backgroundColor = .black

        // No gravity, everything moves via actions
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        setupPlayer()
        setupHUD()
    }

    private func setupPlayer() {
        // Player: white rectangle near bottom of screen
        player = SKSpriteNode(color: .white,
                              size: CGSize(width: 60, height: 20))
        player.position = CGPoint(x: size.width / 2,
                                  y: size.height * 0.15)
        addChild(player)

        // Physics body for player (so asteroids can hit it)
        let body = SKPhysicsBody(rectangleOf: player.size)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.asteroid
        body.collisionBitMask = PhysicsCategory.none
        player.physicsBody = body
    }

    private func setupHUD() {
        scoreLabel = SKLabelNode(fontNamed: "Menlo")
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16,
                                      y: size.height - 40)
        addChild(scoreLabel)

        livesLabel = SKLabelNode(fontNamed: "Menlo")
        livesLabel.fontSize = 18
        livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.position = CGPoint(x: size.width - 16,
                                      y: size.height - 40)
        addChild(livesLabel)

        updateHUD()
    }

    private func updateHUD() {
        scoreLabel.text = "Score: \(score)"
        livesLabel.text = "Lives: \(lives)"
    }

    // MARK: - Game loop
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // asteroid timer
        timeSinceLastAsteroid += delta
        if timeSinceLastAsteroid >= asteroidSpawnInterval {
            spawnAsteroid()
            timeSinceLastAsteroid = 0
        }
    }

    // MARK: - Touch input

    // Fire a bullet when the player taps
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else { return }
        fireBullet()
    }

    // Drag finger to move the player left/right
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Only move on X axis, keep Y fixed
        player.position.x = location.x
    }

    // MARK: - Asteroid logic
    private func spawnAsteroid() {
        let asteroidSize = CGSize(width: 30, height: 30)
        let asteroid = SKSpriteNode(color: .gray, size: asteroidSize)

        let randomX = CGFloat.random(
            in: asteroidSize.width / 2 ... (size.width - asteroidSize.width / 2)
        )
        asteroid.position = CGPoint(x: randomX,
                                    y: size.height + asteroidSize.height)

        addChild(asteroid)

        // Physics body so bullets and player can hit it
        let body = SKPhysicsBody(rectangleOf: asteroidSize)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.asteroid
        body.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        asteroid.physicsBody = body

        let fallDuration: TimeInterval = 4.0
        let moveAction = SKAction.moveTo(y: -asteroidSize.height, duration: fallDuration)
        let removeAction = SKAction.removeFromParent()
        asteroid.run(SKAction.sequence([moveAction, removeAction]))
    }

    // MARK: - Bullet logic
    private func fireBullet() {
        let bulletSize = CGSize(width: 4, height: 18)
        let bullet = SKSpriteNode(color: .cyan, size: bulletSize)

        bullet.position = CGPoint(
            x: player.position.x,
            y: player.position.y + player.size.height / 2 + bulletSize.height / 2
        )

        addChild(bullet)

        // Physics body for bullet
        let body = SKPhysicsBody(rectangleOf: bulletSize)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.bullet
        body.contactTestBitMask = PhysicsCategory.asteroid
        body.collisionBitMask = PhysicsCategory.none
        bullet.physicsBody = body

        let travelTime: TimeInterval = 0.7
        let moveAction = SKAction.moveTo(y: size.height + bulletSize.height, duration: travelTime)
        let removeAction = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([moveAction, removeAction]))
    }

    // MARK: - Physics contact handling
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody

        // Sort bodies so lower categoryBitMask is first
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        let firstCat = firstBody.categoryBitMask
        let secondCat = secondBody.categoryBitMask

        // Bullet vs Asteroid
        if firstCat == PhysicsCategory.asteroid && secondCat == PhysicsCategory.bullet {
            if let asteroid = firstBody.node, let bullet = secondBody.node {
                handleBulletAsteroidCollision(bullet: bullet, asteroid: asteroid)
            }
        }

        // Player vs Asteroid
        if firstCat == PhysicsCategory.player && secondCat == PhysicsCategory.asteroid {
            if let asteroid = secondBody.node {
                handlePlayerAsteroidCollision(asteroid: asteroid)
            }
        }
    }

    private func handleBulletAsteroidCollision(bullet: SKNode, asteroid: SKNode) {
        bullet.removeFromParent()
        asteroid.removeFromParent()

        score += 1
        updateHUD()
    }

    private func handlePlayerAsteroidCollision(asteroid: SKNode) {
        asteroid.removeFromParent()

        lives -= 1
        if lives < 0 { lives = 0 }
        updateHUD()

        // For now just log; later we’ll add a Game Over screen
        if lives == 0 {
            print("GAME OVER")
        }
    }
}
