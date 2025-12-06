import SpriteKit

/// Simple reusable asteroid entity used in gameplay scenes.
final class AsteroidNode: SKSpriteNode {

    static let defaultSize = CGSize(width: 30, height: 30)

    // Convenience initializer: grey square with physics already set up.
    convenience init() {
        self.init(color: .gray, size: AsteroidNode.defaultSize)
        configurePhysics()
    }

    // Designated initializer
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurePhysics()
    }

    /// Configure physics body once so GameScene doesn't have to.
    private func configurePhysics() {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.asteroid
        body.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        physicsBody = body
    }

    /// Returns a random valid X position within the scene for this asteroid size.
    static func randomX(in sceneSize: CGSize) -> CGFloat {
        let w = AsteroidNode.defaultSize.width
        return CGFloat.random(in: w / 2 ... sceneSize.width - w / 2)
    }

    /// Starts a falling animation from just above the top of the scene down off-screen.
    func startFalling(fromTopOf sceneSize: CGSize, duration: TimeInterval) {
        position.y = sceneSize.height + size.height
        let move = SKAction.moveTo(y: -size.height, duration: duration)
        run(.sequence([move, .removeFromParent()]))
    }
}
