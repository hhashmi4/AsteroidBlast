import SpriteKit

class GameScene: SKScene {

    private var lastUpdateTime: TimeInterval = 0
    private var player: SKSpriteNode!

    override func didMove(to view: SKView) {
        backgroundColor = .black

        // Player: white rectangle near bottom of screen
        player = SKSpriteNode(color: .white,
                              size: CGSize(width: 60, height: 20))
        player.position = CGPoint(x: size.width / 2,
                                  y: size.height * 0.15)
        addChild(player)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        _ = delta
    }

    // Move player horizontally with your finger
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Only move on X axis, keep Y fixed
        player.position.x = location.x
    }
}
