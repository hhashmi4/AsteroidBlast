import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let skView = self.view as? SKView {
            // Start app at MenuScene
            let scene = MenuScene(size: skView.bounds.size)
            scene.scaleMode = .resizeFill
            skView.presentScene(scene)

            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

