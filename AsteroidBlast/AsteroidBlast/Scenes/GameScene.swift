import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Time tracking
    private var lastUpdateTime: TimeInterval = 0

    // MARK: - Player
    private var player: PlayerNode!

    // MARK: - Asteroid spawn
    private var timeSinceLastAsteroid: TimeInterval = 0
    private var asteroidSpawnInterval: TimeInterval = 1.2
    private let minAsteroidSpawnInterval: TimeInterval = 0.3

    private var asteroidFallDuration: TimeInterval = 4.0
    private let minAsteroidFallDuration: TimeInterval = 1.2

    // MARK: - Score / Lives / Level
    fileprivate var score: Int = 0
    fileprivate var lives: Int = 3
    private var level: Int = 1

    // MARK: - HUD
    private var hud: HUD!

    // MARK: - Game state
    private var isGameOver: Bool = false
    private var isGamePaused: Bool = false

    // MARK: - Pause overlay
    private var pauseOverlay: PauseOverlay?

    // MARK: - Controls
    private var joystick: Joystick!
    private var joystickTouch: UITouch?
    private var shootButton: SKShapeNode!

    // MARK: - Scene lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = .black

        addBackground()

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        setupPlayer()
        setupHUD()
        setupControls()
    }

    // MARK: - Setup

    private func addBackground() {
        // If you don't have starBackground yet, comment these lines out.
        let texture = SKTexture(imageNamed: "starBackground")
        let background = SKSpriteNode(texture: texture)
        background.size = size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }

    private func setupPlayer() {
        player = PlayerNode()
        player.position = CGPoint(x: size.width / 2,
                                  y: size.height * 0.2)
        addChild(player)
    }

    private func setupHUD() {
        hud = HUD()
        hud.configure(for: size)
        addChild(hud)
        updateHUD()
    }

    private func setupControls() {
        // Joystick (left side)
        joystick = Joystick()
        joystick.configure(for: size)
        addChild(joystick)

        // Shoot button (right side)
        let radius: CGFloat = 40
        shootButton = SKShapeNode(circleOfRadius: radius)
        shootButton.lineWidth = 2
        shootButton.strokeColor = .white.withAlphaComponent(0.7)
        shootButton.fillColor = .white.withAlphaComponent(0.15)

        // Position bottom-right with padding
        shootButton.position = CGPoint(x: size.width - radius - 24,
                                       y: radius + 40)
        shootButton.name = "shootButton"
        addChild(shootButton)
    }

    private func updateHUD() {
        hud.update(score: score, lives: lives, level: level)
    }

    // MARK: - Game loop

    override func update(_ currentTime: TimeInterval) {
        if isGameOver || isGamePaused { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Spawn asteroids over time
        timeSinceLastAsteroid += delta
        if timeSinceLastAsteroid >= asteroidSpawnInterval {
            spawnAsteroid()
            timeSinceLastAsteroid = 0
        }

        // Move player using joystick direction
        applyJoystickMovement(delta: delta)
    }

    private func applyJoystickMovement(delta: TimeInterval) {
        let dir = joystick.direction
        if dir.dx == 0 && dir.dy == 0 { return }

        let speed: CGFloat = 260   // units per second
        let dx = dir.dx * speed * CGFloat(delta)
        let dy = dir.dy * speed * CGFloat(delta)

        let newPosition = CGPoint(
            x: player.position.x + dx,
            y: player.position.y + dy
        )
        player.move(to: newPosition, in: size)
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)

            // Pause / Resume buttons first
            if let nodeName = node.name {
                if nodeName == HUD.pauseButtonName {
                    togglePause()
                    continue
                } else if nodeName == PauseOverlay.resumeButtonName {
                    togglePause()
                    continue
                }
            }

            if isGamePaused || isGameOver { continue }

            // Left side → joystick
            if location.x < size.width / 2 {
                if joystickTouch == nil {
                    joystickTouch = touch
                    joystick.beginTracking(at: location, in: self)
                }
            }
            // Right side → shoot button
            else {
                if shootButton.contains(location) {
                    fireBullet()
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver || isGamePaused { return }

        for touch in touches {
            if touch == joystickTouch {
                let location = touch.location(in: self)
                joystick.updateTracking(at: location, in: self)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchEndOrCancel(touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchEndOrCancel(touches)
    }

    private func handleTouchEndOrCancel(_ touches: Set<UITouch>) {
        for touch in touches {
            if touch == joystickTouch {
                joystick.endTracking()
                joystickTouch = nil
            }
        }
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

    // MARK: - Asteroids

    private func spawnAsteroid() {
            let asteroid = AsteroidNode()

            // Avoid spawning right on top of the player
            let safeRadius: CGFloat = 160

            asteroid.startRandomDrift(
                in: size,
                avoiding: player.position,
                minDistance: safeRadius,
                baseDuration: asteroidFallDuration
            )

            addChild(asteroid)
        }

    // MARK: - Bullets

    private func fireBullet() {
            let bullet = BulletNode()

            // Bullet starts at the nose of the ship
            let startPosition = CGPoint(
                x: player.position.x,
                y: player.position.y + player.size.height / 2
            )

            // Ship artwork points UP, but SpriteKit's zero angle points RIGHT.
            // We stored zRotation as (movementAngle - π/2),
            // so the ship's forward direction is zRotation + π/2.
            let forwardAngle = player.zRotation + (.pi / 2)

            let direction = CGVector(
                dx: cos(forwardAngle),
                dy: sin(forwardAngle)
            )

            addChild(bullet)
            bullet.startMoving(from: startPosition,
                               direction: direction,
                               in: size)
        }

    // MARK: - Physics contacts

    func didBegin(_ contact: SKPhysicsContact) {
        if isGamePaused || isGameOver { return }

        let (a, b) = sortBodies(contact)

        if a.categoryBitMask == PhysicsCategory.asteroid &&
            b.categoryBitMask == PhysicsCategory.bullet,
           let asteroid = a.node, let bullet = b.node {
            handleBulletHitAsteroid(bullet: bullet, asteroid: asteroid)
        }

        if a.categoryBitMask == PhysicsCategory.player &&
            b.categoryBitMask == PhysicsCategory.asteroid,
           let asteroid = b.node {
            handlePlayerHitAsteroid(asteroid: asteroid)
        }
    }

    private func sortBodies(_ contact: SKPhysicsContact) -> (SKPhysicsBody, SKPhysicsBody) {
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            return (contact.bodyA, contact.bodyB)
        } else {
            return (contact.bodyB, contact.bodyA)
        }
    }

    private func handleBulletHitAsteroid(bullet: SKNode, asteroid: SKNode) {
        bullet.removeFromParent()

        if let rock = asteroid as? AsteroidNode {
            let destroyed = rock.takeHit()
            if destroyed {
                score += 1
                updateDifficultyIfNeeded()
                updateHUD()
            }
        } else {
            // Fallback for any non-AsteroidNode
            asteroid.removeFromParent()
            score += 1
            updateDifficultyIfNeeded()
            updateHUD()
        }
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
        asteroidFallDuration = max(minAsteroidFallDuration, asteroidFallDuration * 0.9)

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
                self.view?.presentScene(
                    gameOver,
                    transition: .crossFade(withDuration: 0.7)
                )
            }
        ]))
    }
}
