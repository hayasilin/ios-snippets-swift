import UIKit

class MyViewController: UIViewController {
    let mainDescriptionLabel = UILabel(frame: .zero)

    func addAnimationAppearFromBottom() {
        mainDescriptionLabel.alpha = 0
        mainDescriptionLabel.transform = CGAffineTransform(translationX: 0, y: 40)

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.333, delay: 1) {
            self.mainDescriptionLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            self.mainDescriptionLabel.alpha = 1
        }
    }

    func addAnimationAppearFromBottomAnother() {
        mainDescriptionLabel.alpha = 0

        UIView.animate(withDuration: 0.333) {
            self.mainDescriptionLabel.alpha = 1
            self.mainDescriptionLabel.center.y -= 40
        } completion: { (result) in

        }
    }

    func addAnimationLabelShaker() {
        mainDescriptionLabel.alpha = 0

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0, delay: 1) {
            self.mainDescriptionLabel.alpha = 1
        } completion: { _ in
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.05
            animation.repeatCount = 2
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.mainDescriptionLabel.center.x - 10, y: self.mainDescriptionLabel.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.mainDescriptionLabel.center.x + 10, y: self.mainDescriptionLabel.center.y))
            self.mainDescriptionLabel.layer.add(animation, forKey: "position")
        }
    }

    func useCustomAnimation() {
        let button = UIButton(type: .close)
        let originY = button.frame.origin.y
        UIView.animate(timingFunction: .easeOutQuint, duration: 0.6, delay: 0.07, animations: {
            button.frame.origin.y = originY
            button.alpha = 1
        }, completion: nil)
    }

    func showViewAnimationWithCABasicAnimation() {
        let label = UILabel(frame: .zero)
        label.isHidden = false

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.109
        scaleAnimation.toValue = 1

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1

        let cardShowAnimation = CAAnimationGroup()
        cardShowAnimation.animations = [scaleAnimation, opacityAnimation]
        cardShowAnimation.duration = 0.5
        cardShowAnimation.timingFunction = TimingFunction.easeOutQuint.asCAMediaTimingFunction

        label.layer.add(cardShowAnimation, forKey: "showAnimation")
    }
}

extension UIView {
    static func animate(timingFunction: TimingFunction,
                        duration: TimeInterval,
                        delay: TimeInterval,
                        animations: @escaping (() -> Void),
                        completion: (() -> Void)?) {
        let animator = UIViewPropertyAnimator(duration: duration,
                                              timingParameters: timingFunction.asUITimingCurveProvider)
        animator.addAnimations { animations() }
        animator.addCompletion { _ in
            completion?()
        }
        animator.startAnimation(afterDelay: delay)
    }
}

enum TimingFunction {
    case linear, easeIn, easeOut, easeInOut, easeInQuint, easeOutQuint, easeInOutQuint
}

extension TimingFunction {
    var asUITimingCurveProvider: UITimingCurveProvider {
        switch self {
        case .linear:
            return UICubicTimingParameters(animationCurve: .linear)

        case .easeIn:
            return UICubicTimingParameters(animationCurve: .easeIn)

        case .easeOut:
            return UICubicTimingParameters(animationCurve: .easeOut)

        case .easeInOut:
            return UICubicTimingParameters(animationCurve: .easeInOut)

        case .easeInQuint:
            return UICubicTimingParameters(controlPoint1: CGPoint(x: 0.755, y: 0.05),
                                           controlPoint2: CGPoint(x: 0.855, y: 0.06))

        case .easeOutQuint:
            return UICubicTimingParameters(controlPoint1: CGPoint(x: 0.23, y: 1),
                                           controlPoint2: CGPoint(x: 0.32, y: 1))

        case .easeInOutQuint:
            return UICubicTimingParameters(controlPoint1: CGPoint(x: 0.86, y: 0),
                                           controlPoint2: CGPoint(x: 0.07, y: 1))
        }
    }

    var asCAMediaTimingFunction: CAMediaTimingFunction {
        switch self {
        case .linear:
            return CAMediaTimingFunction(name: .linear)

        case .easeIn:
            return CAMediaTimingFunction(name: .easeIn)

        case .easeOut:
            return CAMediaTimingFunction(name: .easeOut)

        case .easeInOut:
            return CAMediaTimingFunction(name: .easeInEaseOut)

        case .easeInQuint:
            return CAMediaTimingFunction(controlPoints: 0.755, 0.05, 0.855, 0.06)

        case .easeOutQuint:
            return CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)

        case .easeInOutQuint:
            return CAMediaTimingFunction(controlPoints: 0.86, 0, 0.07, 1)
        }
    }
}
