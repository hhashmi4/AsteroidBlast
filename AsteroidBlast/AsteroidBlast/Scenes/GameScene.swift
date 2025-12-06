import SpriteKit

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
    private var pauseLabel: SKLabelNode!

    // MARK: - Game state
    private var isGameOver: Bool = false
    private var isGamePaused: Bool = false

    // MARK: - Pause overlay
    private var pauseOverlay: PauseOverlay?

    // MARK: - Scene lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = .black

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        setupPlayer()
        setupHUD()
    }

    // MARK: - Setup helpers

    private func setupPlayer() {
        player = SKSpriteNode(color: .white, size: CGSize(width: 60, height: 20))
        player.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        addChild(player)

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
        scoreLabel.position = CGPoint(x: 16, y: size.height - 40)
        addChild(scoreLabel)

        // Lives (right)
        livesLabel = SKLabelNode(fontNamed: "Menlo")
        livesLabel.fontSize = 18
        livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.position = CGPoint(x: size.width - 16, y: size.height - 40)
        addChild(livesLabel)

        // Level (top center)
        levelLabel = SKLabelNode(fontNamed: "Menlo")
        levelLabel.fontSize = 18
        levelLabel.fontColor = .white
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.position = CGPoint(x: size.width / 2, y: size.height - 40)
        addChild(levelLabel)

        // Pause (below lives)
        pauseLabel = SKLabelNode(fontNamed: "Menlo")
        pauseLabel.text = "Pause"
        pauseLabel.fontSize = 14
        pauseLabel.fontColor = .yellow
        pauseLabel.horizontalAlignmentMode = .right
        pauseLabel.position = CGPoint(x: size.width - 16, y: size.height - 65)
        pauseLabel.name = "pauseButton"
        addChild(pauseLabel)

        updateHUD()
    }

    private func updateHUD() {
        scoreLabel.text = "Score: \(score)"
        livesLabel.text = "Lives: \(lives)"
        levelLabel.text = "Level: \(level)"
    }

    // MARK: - Game loop
    override func update(_ currentTime: TimeInterval) {
        if isGameOver || isGamePaused { return }

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

    // MARK: - Input handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)

        // Pause and resume
        if let nodeName = node.name {
            if nodeName == "pauseButton" {
                togglePause()
                return
            } else if nodeName == PauseOverlay.resumeButtonName {
                togglePause()
                return
            }
        }

        if isGamePaused || isGameOver { return }

        fireBullet()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver || isGamePaused { return }

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        player.position.x = location.x
    }

    // MARK: - Pause

    private func togglePause() {
        isGamePaused.toggle()

        if isGamePaused {
            showPauseOverlay()
        } else {
            hidePauseOverlay()
        }
    }

    private func showPauseOverlay() {
        if pauseOverlay == nil {
            let overlay = PauseOverlay()
            overlay.configure(for: size)
            pauseOverlay = overlay
            addChild(overlay)
        }
    }

    private func hidePauseOverlay() {
        pauseOverlay?.removeFromParent()
        pauseOverlay = nil
    }

    // MARK: - Asteroids

    private func spawnAsteroid() {
        let asteroidSize = CGSize(width: 30, height: 30)
        let asteroid = SKSpriteNode(color: .gray, size: asteroidSize)

        let randomX = CGFloat.random(in: asteroidSize.width/2 ... size.width - asteroidSize.width/2)
        asteroid.position = CGPoint(x: randomX, y: size.height + asteroidSize.height)
        addChild(asteroid)

        let body = SKPhysicsBody(rectangleOf: asteroidSize)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.asteroid
        body.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        asteroid.physicsBody = body

        let fall = SKAction.moveTo(y: -asteroidSize.height, duration: asteroidFallDuration)
        asteroid.run(SKAction.sequence([fall, .removeFromParent()]))
    }

    // MARK: - Bullets

    private func fireBullet() {
        let bullet = SKSpriteNode(color: .cyan, size: CGSize(width: 4, height: 18))
        bullet.position = CGPoint(x: player.position.x,
                                  y: player.position.y + player.size.height/2 + 10)
        addChild(bullet)

        let body = SKPhysicsBody(rectangleOf: bullet.size)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.bullet
        body.contactTestBitMask = PhysicsCategory.asteroid
        body.collisionBitMask = PhysicsCategory.none
        bullet.physicsBody = body

        let move = SKAction.moveTo(y: size.height + 30, duration: 0.7)
        bullet.run(SKAction.sequence([move, .removeFromParent()]))
    }

    // MARK: - Physics contacts

    func didBegin(_ contact: SKPhysicsContact) {
        if isGamePaused || isGameOver { return }

        let (a, b) = sortBodies(contact)

        if a.categoryBitMask == PhysicsCategory.asteroid &&
           b.categoryBitMask == PhysicsCategory.bullet {
            handleBulletHitAsteroid(bullet: b.node!, asteroid: a.node!)
        }

        if a.categoryBitMask == PhysicsCategory.player &&
           b.categoryBitMask == PhysicsCategory.asteroid {
            handlePlayerHitAsteroid(asteroid: b.node!)
        }
    }

    private func sortBodies(_ contact: SKPhysicsContact)
        -> (SKPhysicsBody, SKPhysicsBody)
    {
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            return (contact.bodyA, contact.bodyB)
        } else {
            return (contact.bodyB, contact.bodyA)
        }
    }

    private func handleBulletHitAsteroid(bullet: SKNode, asteroid: SKNode) {
        bullet.removeFromParent()
        asteroid.removeFromParent()

        score += 1
        updateDifficultyIfNeeded()
        updateHUD()
    }

    private func handlePlayerHitAsteroid(asteroid: SKNode) {
        asteroid.removeFromParent()
        lives -= 1
        updateHUD()

        if lives <= 0 {
            triggerGameOver()
        }
    }

    // MARK: - Difficulty / Levels

    private func updateDifficultyIfNeeded() {
        let newLevel = max(1, score / 10 + 1)

        if newLevel > level {
            level = newLevel
            applyDifficultyForCurrentLevel()
        }
    }

    private func applyDifficultyForCurrentLevel() {
        asteroidSpawnInterval = max(minAsteroidSpawnInterval, asteroidSpawnInterval * 0.9)
        asteroidFallDuration   = max(minAsteroidFallDuration, asteroidFallDuration * 0.9)

        showLevelUpLabel()
        updateHUD()
    }

    private func showLevelUpLabel() {
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = "Level \(level)"
        label.fontSize = 28
        label.fontColor = .yellow
        label.position = CGPoint(x: size.width/2, y: size.height * 0.7)
        label.alpha = 0
        addChild(label)

        label.run(.sequence([
            .fadeIn(withDuration: 0.2),
            .wait(forDuration: 0.6),
            .fadeOut(withDuration: 0.4),
            .removeFromParent()
        ]))
    }

    // MARK: - Game Over

    private func triggerGameOver() {
        isGameOver = true

        run(.sequence([
            .wait(forDuration: 0.5),
            .run { [weak self] in
                guard let self = self else { return }
                let gameOver = GameOverScene(size: self.size)
                gameOver.finalScore = self.score
                gameOver.scaleMode = self.scaleMode
                self.view?.presentScene(gameOver,
                    transition: .crossFade(withDuration: 0.7))
            }
        ]))
    }
}
