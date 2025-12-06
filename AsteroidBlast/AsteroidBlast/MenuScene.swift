import SpriteKit

class MenuScene: SKScene {

    private var titleLabel: SKLabelNode!
    private var playLabel: SKLabelNode!
    private var infoLabel: SKLabelNode!

    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black

        // Title
        titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        titleLabel.text = "AsteroidBlast"
        titleLabel.fontSize = 42
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2,
                                      y: size.height * 0.6)
        addChild(titleLabel)

        // Play "button" (label)
        playLabel = SKLabelNode(fontNamed: "Menlo")
        playLabel.text = "Tap to Play"
        playLabel.fontSize = 26
        playLabel.fontColor = .cyan
        playLabel.position = CGPoint(x: size.width / 2,
                                     y: size.height * 0.45)
        playLabel.name = "playButton"   // so we can detect taps
        addChild(playLabel)

        // Info text
        infoLabel = SKLabelNode(fontNamed: "Menlo")
        infoLabel.text = "Drag to move • Tap to shoot"
        infoLabel.fontSize = 16
        infoLabel.fontColor = .gray
        infoLabel.position = CGPoint(x: size.width / 2,
                                     y: size.height * 0.32)
        addChild(infoLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)

        // If we tap the "play" label, start the game
        if node.name == "playButton" || node == playLabel {
            startGame()
        } else {
            // Also allow tapping anywhere to start if you want
            startGame()
        }
    }

    private func startGame() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .resizeFill
        view?.presentScene(
            gameScene,
            transition: SKTransition.fade(withDuration: 0.7)
        )
    }
}

