import SpriteKit

/// Simple reusable asteroid entity used in gameplay scenes.
final class AsteroidNode: SKSpriteNode {

    static let baseSize = CGSize(width: 40, height: 40)

    /// Current health of the asteroid. Bigger ones have more HP.
    private(set) var hitPoints: Int = 1

    // Convenience initializer: asteroid texture with random size, HP and spin.
    convenience init() {
        let texture = SKTexture(imageNamed: "asteroid")

        // Random size scale: small to large rock
        let scale = CGFloat.random(in: 0.6...1.6)
        let size = CGSize(width: AsteroidNode.baseSize.width * scale,
                          height: AsteroidNode.baseSize.height * scale)

        self.init(texture: texture,
                  color: .clear,
                  size: size)

        // HP based on size (1–3 hits roughly)
        hitPoints = max(1, Int(round(scale * 2)))

        configurePhysics()
        applyRandomSpin()
    }

    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurePhysics()
        applyRandomSpin()
    }

    /// Basic physics: only collides via contacts, no bouncing.
    private func configurePhysics() {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.asteroid
        body.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        physicsBody = body
    }

    /// Give the rock a continuous random spin.
    private func applyRandomSpin() {
        let direction: CGFloat = Bool.random() ? 1 : -1
        let rotationsPerSecond = CGFloat.random(in: 0.2...0.8)
        let anglePerSecond = direction * .pi * 2 * rotationsPerSecond

        let duration: TimeInterval = 1.0
        let rotate = SKAction.rotate(byAngle: anglePerSecond * duration,
                                     duration: duration)
        run(SKAction.repeatForever(rotate))
    }

    // MARK: - Damage / death

    /// Apply one hit of damage.
    /// Returns true if the asteroid was destroyed.
    @discardableResult
    func takeHit() -> Bool {
        hitPoints -= 1

        if hitPoints <= 0 {
            explodeAndRemove()
            return true
        } else {
            // Small hit flash
            let flash = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 0.05),
                SKAction.fadeAlpha(to: 1.0, duration: 0.05)
            ])
            run(flash)
            return false
        }
    }

    private func explodeAndRemove() {
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let remove = SKAction.removeFromParent()
        run(SKAction.sequence([scaleUp, fadeOut, remove]))
    }

    // MARK: - Random multi-direction movement with player-aware spawn

    /// Returns a random start + target point so the asteroid
    /// moves across the screen from one edge to another, while
    /// trying to avoid spawning too close to the player.
    private static func randomPath(avoiding playerPosition: CGPoint?,
                                   minDistance: CGFloat,
                                   in sceneSize: CGSize) -> (start: CGPoint, target: CGPoint) {

        let w = sceneSize.width
        let h = sceneSize.height
        let margin: CGFloat = 60   // spawn just off-screen

        var best: (start: CGPoint, target: CGPoint)?

        // Try a few times to find a spawn not too close to player
        for _ in 0..<8 {
            let side = Int.random(in: 0..<4) // 0: top, 1: bottom, 2: left, 3: right
            let start: CGPoint
            let target: CGPoint

            switch side {
            case 0: // from top
                let startX = CGFloat.random(in: 0...w)
                let targetX = CGFloat.random(in: 0...w)
                start = CGPoint(x: startX, y: h + margin)
                target = CGPoint(x: targetX, y: -margin)

            case 1: // from bottom
                let startX = CGFloat.random(in: 0...w)
                let targetX = CGFloat.random(in: 0...w)
                start = CGPoint(x: startX, y: -margin)
                target = CGPoint(x: targetX, y: h + margin)

            case 2: // from left
                let startY = CGFloat.random(in: 0...h)
                let targetY = CGFloat.random(in: 0...h)
                start = CGPoint(x: -margin, y: startY)
                target = CGPoint(x: w + margin, y: targetY)

            default: // from right
                let startY = CGFloat.random(in: 0...h)
                let targetY = CGFloat.random(in: 0...h)
                start = CGPoint(x: w + margin, y: startY)
                target = CGPoint(x: -margin, y: targetY)
            }

            best = (start, target)

            // If no player or safely far away, use this spawn
            if let playerPos = playerPosition {
                let dx = start.x - playerPos.x
                let dy = start.y - playerPos.y
                let dist = sqrt(dx * dx + dy * dy)
                if dist >= minDistance {
                    return (start, target)
                }
            } else {
                return (start, target)
            }
        }

        // Fallback to whatever we last generated
        return best ?? (CGPoint(x: w / 2, y: h + margin),
                        CGPoint(x: w / 2, y: -margin))
    }

    /// Start drifting across the screen from a random edge toward a random opposite edge,
    /// avoiding spawning too close to the given player position.
    func startRandomDrift(in sceneSize: CGSize,
                          avoiding playerPosition: CGPoint?,
                          minDistance: CGFloat,
                          baseDuration: TimeInterval) {

        let path = AsteroidNode.randomPath(avoiding: playerPosition,
                                           minDistance: minDistance,
                                           in: sceneSize)
        position = path.start

        let dx = path.target.x - path.start.x
        let dy = path.target.y - path.start.y
        let distance = sqrt(dx * dx + dy * dy)

        // Use distance to scale duration so further paths take a bit longer,
        // but still controlled by baseDuration.
        let screenDiagonal = sqrt(sceneSize.width * sceneSize.width +
                                  sceneSize.height * sceneSize.height)
        let distanceFactor = max(0.7, min(1.3, distance / screenDiagonal))
        let duration = baseDuration * Double(distanceFactor)

        let move = SKAction.move(to: path.target, duration: duration)
        run(.sequence([move, .removeFromParent()]))
    }
}
