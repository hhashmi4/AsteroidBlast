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
    private var asteroidSpawnInterval: TimeInterval = 1.2        // starts easy
    private let minAsteroidSpawnInterval: TimeInterval = 0.3     // cap difficulty

    private var asteroidFallDuration: TimeInterval = 4.0         // starts slow
    private let minAsteroidFallDuration: TimeInterval = 1.2      // fastest allowed

    // MARK: - Score / Lives / Level
    fileprivate var score: Int = 0
    fileprivate var lives: Int = 3
    private var level: Int = 1

    private var scoreLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!
    private var levelLabel: SKLabelNode!

    // MARK: - Game state
    private var isGameOver: Bool = false

    // MARK: - Scene setup
    override func didMove(to view: SKView) {
        backgroundColor = .black

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

        // Physics body for player
        let body = SKPhysicsBody(rectangleOf: player.size)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.asteroid
        body.collisionBitMask = PhysicsCategory.none
        player.physicsBody = body
    }

    private func setupHUD() {
        // Score (left)
        scoreLabel = SKLabelNode(fontNamed: "Menlo")
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16,
                                      y: size.height - 40)
        addChild(scoreLabel)

        // Lives (right)
        livesLabel = SKLabelNode(fontNamed: "Menlo")
        livesLabel.fontSize = 18
        livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.position = CGPoint(x: size.width - 16,
                                      y: size.height - 40)
        addChild(livesLabel)

        // Level (center top)
        levelLabel = SKLabelNode(fontNamed: "Menlo")
        levelLabel.fontSize = 18
        levelLabel.fontColor = .white
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.position = CGPoint(x: size.width / 2,
                                      y: size.height - 40)
        addChild(levelLabel)

        updateHUD()
    }

    private func updateHUD() {
        scoreLabel.text = "Score: \(score)"
        livesLabel.text = "Lives: \(lives)"
        levelLabel.text = "Level: \(level)"
    }

    // MARK: - Game loop
    override func update(_ currentTime: TimeInterval) {
        if isGameOver { return }   // stop spawning once game is over

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        timeSinceLastAsteroid += delta
        if timeSinceLastAsteroid >= asteroidSpawnInterval {
            spawnAsteroid()
            timeSinceLastAsteroid = 0
        }
    }

    // MARK: - Touch input

    // Fire a bullet when the player taps
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver { return }
        guard touches.first != nil else { return }
        fireBullet()
    }

    // Drag finger to move the player left/right
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver { return }
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

        // Use current difficulty level for fall speed
        let fallDuration = asteroidFallDuration
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
        if isGameOver { return }

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
        updateDifficultyIfNeeded()
        updateHUD()
    }

    private func handlePlayerAsteroidCollision(asteroid: SKNode) {
        asteroid.removeFromParent()

        lives -= 1
        if lives < 0 { lives = 0 }
        updateHUD()

        if lives == 0 {
            triggerGameOver()
        }
    }

    // MARK: - Difficulty / Level logic

    private func updateDifficultyIfNeeded() {
        // Example rule:
        // Every 10 points, increase level by 1
        let newLevel = max(1, score / 10 + 1)

        if newLevel > level {
            level = newLevel
            applyDifficultyForCurrentLevel()
        }
    }

    private func applyDifficultyForCurrentLevel() {
        // Each level:
        // - spawn a bit faster
        // - asteroids fall a bit faster
        // but never go beyond min values

        // Decrease spawn interval by 10% per level
        asteroidSpawnInterval = max(
            minAsteroidSpawnInterval,
            asteroidSpawnInterval * 0.9
        )

        // Decrease fall duration by 10% per level
        asteroidFallDuration = max(
            minAsteroidFallDuration,
            asteroidFallDuration * 0.9
        )

        // Optional: show a quick level-up message
        showLevelUpLabel()

        updateHUD()
    }

    private func showLevelUpLabel() {
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "Level \(level)"
        label.fontSize = 28
        label.fontColor = .yellow
        label.position = CGPoint(x: size.width / 2,
                                 y: size.height * 0.7)
        label.alpha = 0.0
        addChild(label)

        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let wait = SKAction.wait(forDuration: 0.6)
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        let remove = SKAction.removeFromParent()
        label.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }

    // MARK: - Game Over

    private func triggerGameOver() {
        isGameOver = true

        let wait = SKAction.wait(forDuration: 0.5)
        let transitionAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            let gameOverScene = GameOverScene(size: self.size)
            gameOverScene.finalScore = self.score
            gameOverScene.scaleMode = self.scaleMode

            self.view?.presentScene(
                gameOverScene,
                transition: SKTransition.crossFade(withDuration: 0.7)
            )
        }

        run(SKAction.sequence([wait, transitionAction]))
    }
}

