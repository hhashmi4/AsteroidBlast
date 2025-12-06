import SpriteKit

class PauseOverlay: SKNode {

    static let resumeButtonName = "resumeButton"

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(for size: CGSize) {
        // Clear any previous children (if re-used)
        removeAllChildren()

        // Background panel
        let panelSize = CGSize(width: size.width * 0.8, height: size.height * 0.4)
        let background = SKShapeNode(rectOf: panelSize, cornerRadius: 16)
        background.fillColor = SKColor.black.withAlphaComponent(0.8)
        background.strokeColor = SKColor.white.withAlphaComponent(0.4)
        background.lineWidth = 2
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(background)

        // Title
        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.text = "Paused"
        title.fontSize = 32
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 30)
        background.addChild(title)

        // Info
        let info = SKLabelNode(fontNamed: "Menlo")
        info.text = "Tap Resume to continue"
        info.fontSize = 18
        info.fontColor = .gray
        info.position = CGPoint(x: 0, y: -5)
        background.addChild(info)

        // Resume button
        let resume = SKLabelNode(fontNamed: "Menlo")
        resume.text = "Resume"
        resume.fontSize = 20
        resume.fontColor = .cyan
        resume.name = PauseOverlay.resumeButtonName
        resume.position = CGPoint(x: 0, y: -45)
        background.addChild(resume)
    }
}
