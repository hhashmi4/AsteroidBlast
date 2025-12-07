import SpriteKit

/// Player ship entity controlled by the user.
final class PlayerNode: SKSpriteNode {

    // Size of the ship on screen. Adjust if it looks too big/small.
    static let defaultSize = CGSize(width: 64, height: 64)

    // Convenience init: uses the playerShip texture from Assets.xcassets.
    convenience init() {
        let texture = SKTexture(imageNamed: "playerShip")
        self.init(texture: texture,
                  color: .clear,
                  size: PlayerNode.defaultSize)
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

    /// Move freely in 2D, clamped inside the visible play area,
    /// and rotate the ship to face the direction of movement.
    func move(to point: CGPoint, in sceneSize: CGSize) {
        let previousPosition = position   // where we were before

        let halfW = size.width / 2
        let halfH = size.height / 2

        // Clamp X to stay on screen
        let clampedX = max(halfW, min(sceneSize.width - halfW, point.x))

        // Clamp Y so we don't go under the bottom or into the HUD at top
        let minY = halfH + 20                 // keep a bit above very bottom
        let maxY = sceneSize.height - halfH - 80   // avoid overlapping HUD
        let clampedY = max(minY, min(maxY, point.y))

        let newPosition = CGPoint(x: clampedX, y: clampedY)
        position = newPosition

        // --- Rotation: face movement direction ---

        let dx = newPosition.x - previousPosition.x
        let dy = newPosition.y - previousPosition.y

        // If we actually moved a noticeable amount, rotate.
        let distanceSquared = dx * dx + dy * dy
        if distanceSquared > 1 {   // ignore tiny jitter
            // SpriteKit's 0 rad points to the RIGHT.
            // Our ship art points UP, which is +π/2 radians.
            let movementAngle = atan2(dy, dx)
            zRotation = movementAngle - (.pi / 2)
        }
    }
}
