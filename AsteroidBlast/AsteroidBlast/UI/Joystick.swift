
import SpriteKit

/// Simple on-screen joystick for 2D movement.
/// - Left side of the screen.
/// - Exposes a normalized direction vector (dx, dy in [-1, 1]).
final class Joystick: SKNode {

    private let base: SKShapeNode
    private let knob: SKShapeNode
    private let radius: CGFloat

    /// Current normalized direction of the joystick.
    /// (0,0) = idle, length <= 1.
    private(set) var direction: CGVector = .zero

    override init() {
        self.radius = 50

        // Outer circle
        base = SKShapeNode(circleOfRadius: radius)
        base.lineWidth = 2
        base.strokeColor = .white.withAlphaComponent(0.6)
        base.fillColor = .black.withAlphaComponent(0.2)

        // Inner knob
        knob = SKShapeNode(circleOfRadius: radius * 0.4)
        knob.lineWidth = 1
        knob.strokeColor = .white
        knob.fillColor = .white.withAlphaComponent(0.8)

        super.init()

        isUserInteractionEnabled = false   // GameScene handles touches

        base.position = .zero
        knob.position = .zero

        addChild(base)
        addChild(knob)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Call after creating to place joystick on screen.
    func configure(for sceneSize: CGSize) {
        // Place bottom-left with some padding
        position = CGPoint(x: radius + 24,
                           y: radius + 40)
    }

    /// Start tracking a touch at given scene location.
    func beginTracking(at sceneLocation: CGPoint, in node: SKNode) {
        let local = convert(sceneLocation, from: node)
        updateKnob(with: local)
    }

    /// Continue tracking as the touch moves.
    func updateTracking(at sceneLocation: CGPoint, in node: SKNode) {
        let local = convert(sceneLocation, from: node)
        updateKnob(with: local)
    }

    /// Stop tracking when touch ends.
    func endTracking() {
        direction = .zero
        knob.run(SKAction.move(to: .zero, duration: 0.1))
    }

    // MARK: - Internal

    private func updateKnob(with localPoint: CGPoint) {
        let dx = localPoint.x
        let dy = localPoint.y
        let vector = CGVector(dx: dx, dy: dy)

        let length = sqrt(dx * dx + dy * dy)

        if length <= radius || length == 0 {
            knob.position = localPoint
            direction = length == 0 ? .zero : CGVector(dx: dx / length, dy: dy / length)
        } else {
            // Clamp knob to circle edge
            let clampedX = dx / length * radius
            let clampedY = dy / length * radius
            knob.position = CGPoint(x: clampedX, y: clampedY)
            direction = CGVector(dx: clampedX / radius, dy: clampedY / radius)
        }
    }
}
