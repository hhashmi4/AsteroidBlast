import SpriteKit

class GameScene: SKScene {

    private var lastUpdateTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        backgroundColor = .black

        // Placeholder label so we know our scene is loaded
        let titleLabel = SKLabelNode(text: "AsteroidBlast")
        titleLabel.fontSize = 40
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2,
                                      y: size.height / 2)
        addChild(titleLabel)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // we'll use delta later for movement, timers, etc.
        _ = delta
    }
}

