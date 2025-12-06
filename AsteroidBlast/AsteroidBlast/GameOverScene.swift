import SpriteKit

class GameOverScene: SKScene {

    // Score to show from the previous game
    var finalScore: Int = 0

    private var titleLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var infoLabel: SKLabelNode!

    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black

        // "Game Over" title
        titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        titleLabel.text = "Game Over"
        titleLabel.fontSize = 42
        titleLabel.fontColor = .red
        titleLabel.position = CGPoint(x: size.width / 2,
                                      y: size.height * 0.6)
        addChild(titleLabel)

        // Final score
        scoreLabel = SKLabelNode(fontNamed: "Menlo")
        scoreLabel.text = "Score: \(finalScore)"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2,
                                      y: size.height * 0.5)
        addChild(scoreLabel)

        // Instruction text
        infoLabel = SKLabelNode(fontNamed: "Menlo")
        infoLabel.text = "Tap anywhere to play again"
        infoLabel.fontSize = 18
        infoLabel.fontColor = .gray
        infoLabel.position = CGPoint(x: size.width / 2,
                                     y: size.height * 0.35)
        addChild(infoLabel)
    }

    // Restart game on tap
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newGame = GameScene(size: size)
        newGame.scaleMode = .resizeFill
        view?.presentScene(newGame,
                           transition: SKTransition.fade(withDuration: 0.7))
    }
}
