import UIKit

class MyAnotherViewController: UIViewController {

}

class MyViewController: UIViewController {
    func presentViewController() {
        // Present another view controll from story board
        let storyboard = UIStoryboard(name: "MyStoryBoardName", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "MyStoryBoardName") as? MyAnotherViewController else {
            return
        }

        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
