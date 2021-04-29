import UIKit

class MyViewController: UIViewController {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        // Load xib in UIViewController
        #if DEBUG
        super.init(nibName: "MyXibName", bundle: nil)
        #else
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        #endif
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
}

class MyView: UIView {
    func loadMyXibView() {
        // Load xib as a view
        #if DEBUG
        guard let view = Bundle.main.loadNibNamed("MyXibName", owner: self, options: nil)?.first as? UIView else { return }
        #else
        guard let xibName = NSStringFromClass(self.classForCoder).components(separatedBy: ".").last,
              let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as? UIView else { return }
        #endif
        self.addSubview(view)
        view.fillToSuperview()
    }

    func loadMyXibViewAnother() {
        #if DEBUG
        guard let view = Bundle.main.loadNibNamed("MyXibName", owner: self, options: nil)?.first as? UIView else { return }
        #else
        guard let view = Bundle.main.loadNibNamed("MyXibName", owner: self, options: nil)?.first as? UIView else { return }
        #endif
    }
}

extension UIView {
    func fillToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            let left = leftAnchor.constraint(equalTo: superview.leftAnchor)
            let right = rightAnchor.constraint(equalTo: superview.rightAnchor)
            let top = topAnchor.constraint(equalTo: superview.topAnchor)
            let bottom = bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            NSLayoutConstraint.activate([left, right, top, bottom])
        }
    }
}
