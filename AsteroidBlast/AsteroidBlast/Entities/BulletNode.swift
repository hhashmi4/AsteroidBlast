import SpriteKit

/// Simple reusable bullet entity fired by the player.
final class BulletNode: SKSpriteNode {

    static let defaultSize = CGSize(width: 4, height: 18)

    // Convenience initializer: cyan rectangle with physics already set up.
    convenience init() {
        self.init(color: .cyan, size: BulletNode.defaultSize)
        configurePhysics()
    }

    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurePhysics()
    }

    /// Configure physics so bullets only interact with asteroids.
    private func configurePhysics() {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.bullet
        body.contactTestBitMask = PhysicsCategory.asteroid
        body.collisionBitMask = PhysicsCategory.none
        physicsBody = body
    }

    /// Start moving the bullet straight up until it leaves the screen.
    func startMoving(from startPosition: CGPoint,
                     in sceneSize: CGSize,
                     duration: TimeInterval = 0.7) {
        position = startPosition

        let move = SKAction.moveTo(y: sceneSize.height + size.height, duration: duration)
        run(.sequence([move, .removeFromParent()]))
    }
}
