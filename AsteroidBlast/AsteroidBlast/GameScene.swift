import SpriteKit

class GameScene: SKScene {

    // MARK: - Time tracking
    private var lastUpdateTime: TimeInterval = 0

    // MARK: - Player
    private var player: SKSpriteNode!

    // MARK: - Asteroid spawn
    private var timeSinceLastAsteroid: TimeInterval = 0
    private let asteroidSpawnInterval: TimeInterval = 1.2  // seconds

    // MARK: - Scene setup
    override func didMove(to view: SKView) {
        backgroundColor = .black

        // Player: white rectangle near bottom of screen
        player = SKSpriteNode(color: .white,
                              size: CGSize(width: 60, height: 20))
        player.position = CGPoint(x: size.width / 2,
                                  y: size.height * 0.15)
        addChild(player)
    }

    // MARK: - Game loop
    override func update(_ currentTime: TimeInterval) {
        // delta time
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

    // Fire a bullet when the player first touches the screen
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

        let randomX = CGFloat.random(in: asteroidSize.width / 2 ... (size.width - asteroidSize.width / 2))
        asteroid.position = CGPoint(x: randomX,
                                    y: size.height + asteroidSize.height)

        addChild(asteroid)

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

        // Move up and then remove
        let travelTime: TimeInterval = 0.7
        let moveAction = SKAction.moveTo(y: size.height + bulletSize.height, duration: travelTime)
        let removeAction = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([moveAction, removeAction]))
    }
}

