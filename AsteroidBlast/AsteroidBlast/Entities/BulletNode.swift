import SpriteKit

/// Simple reusable bullet entity fired by the player.
final class BulletNode: SKSpriteNode {

    static let defaultSize = CGSize(width: 6, height: 18)

    // Convenience initializer: texture + physics
    convenience init() {
        let texture = SKTexture(imageNamed: "bullet")
        self.init(texture: texture,
                  color: .clear,
                  size: BulletNode.defaultSize)
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

    /// Fire the bullet in a given direction from a start position.
    /// - Parameters:
    ///   - startPosition: where the bullet starts (usually nose of ship)
    ///   - direction: normalized direction vector (length ~1)
    ///   - sceneSize: used to pick a distance far off-screen
    ///   - duration: how fast to travel
    func startMoving(from startPosition: CGPoint,
                     direction: CGVector,
                     in sceneSize: CGSize,
                     duration: TimeInterval = 0.7) {

        position = startPosition

        // Choose a distance large enough to exit the screen.
        let maxDimension = max(sceneSize.width, sceneSize.height)
        let travelDistance: CGFloat = maxDimension + 200

        let dx = direction.dx * travelDistance
        let dy = direction.dy * travelDistance

        let targetPoint = CGPoint(x: startPosition.x + dx,
                                  y: startPosition.y + dy)

        let move = SKAction.move(to: targetPoint, duration: duration)
        run(.sequence([move, .removeFromParent()]))
    }
}
