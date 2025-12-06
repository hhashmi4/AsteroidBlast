import SpriteKit

/// Heads-up display for score, lives, level and pause button.
class HUD: SKNode {

    static let pauseButtonName = "pauseButton"

    private var scoreLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!
    private var levelLabel: SKLabelNode!
    private var pauseLabel: SKLabelNode!

    /// Call after init to lay out labels.
    func configure(for size: CGSize) {
        removeAllChildren()

        // Score (left)
        scoreLabel = SKLabelNode(fontNamed: "Menlo")
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: size.height - 40)
        addChild(scoreLabel)

        // Lives (right)
        livesLabel = SKLabelNode(fontNamed: "Menlo")
        livesLabel.fontSize = 18
        livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.position = CGPoint(x: size.width - 16, y: size.height - 40)
        addChild(livesLabel)

        // Level (center top)
        levelLabel = SKLabelNode(fontNamed: "Menlo")
        levelLabel.fontSize = 18
        levelLabel.fontColor = .white
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.position = CGPoint(x: size.width / 2, y: size.height - 40)
        addChild(levelLabel)

        // Pause (under lives)
        pauseLabel = SKLabelNode(fontNamed: "Menlo")
        pauseLabel.text = "Pause"
        pauseLabel.fontSize = 14
        pauseLabel.fontColor = .yellow
        pauseLabel.horizontalAlignmentMode = .right
        pauseLabel.position = CGPoint(x: size.width - 16, y: size.height - 65)
        pauseLabel.name = HUD.pauseButtonName
        addChild(pauseLabel)
    }

    /// Update numbers displayed.
    func update(score: Int, lives: Int, level: Int) {
        scoreLabel.text = "Score: \(score)"
        livesLabel.text = "Lives: \(lives)"
        levelLabel.text = "Level: \(level)"
    }
}
