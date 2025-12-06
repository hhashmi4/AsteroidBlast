import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let skView = self.view as? SKView {
            let scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .resizeFill
            skView.presentScene(scene)

            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        true
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
