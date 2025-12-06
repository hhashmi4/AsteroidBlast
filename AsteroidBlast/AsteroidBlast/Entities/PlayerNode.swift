
import SpriteKit

/// Player ship entity controlled by the user.
final class PlayerNode: SKSpriteNode {

    static let defaultSize = CGSize(width: 60, height: 20)

    // Convenience init: white rectangle with physics.
    convenience init() {
        self.init(color: .white, size: PlayerNode.defaultSize)
        configurePhysics()
    }

    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurePhysics()
    }

    private func configurePhysics() {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.asteroid
        body.collisionBitMask = PhysicsCategory.none
        physicsBody = body
    }

    /// Move horizontally, clamped so the player doesn't go off-screen.
    func moveHorizontally(to x: CGFloat, in sceneSize: CGSize) {
        let halfWidth = size.width / 2
        let clampedX = max(halfWidth, min(sceneSize.width - halfWidth, x))
        position.x = clampedX
    }
}
