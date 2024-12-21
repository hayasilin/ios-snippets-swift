//
//  KeyboardAppearanceObserverInfo.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import UIKit

@objc
public final class KeyboardAppearanceObserverInfo: NSObject {
    @objc public let animationCurve: UIView.AnimationCurve
    @objc public let animationCurveOptions: UIView.AnimationOptions
    @objc public let animationDuration: TimeInterval

    @objc public let originalEndFrame: CGRect
    @objc public let endFrame: CGRect
    @objc public let intersectionRect: CGRect

    @objc public let isUndocked: Bool
    @objc public let isKeyboardVisible: Bool

    // `true` if keyboard is opened within app. `false` if other app opens keyboard.
    @objc public let isLocalKeyboard: Bool

    public let isExternalKeyboardToolbar: Bool

    init(
        animationCurve: UIView.AnimationCurve,
        animationCurveOptions: UIView.AnimationOptions,
        animationDuration: TimeInterval,
        originalEndFrame: CGRect,
        endFrame: CGRect,
        intersectionRect: CGRect,
        isUndocked: Bool,
        isKeyboardVisible: Bool,
        isLocalKeyboard: Bool,
        isExternalKeyboardToolbar: Bool
    ) {
        self.animationCurve = animationCurve
        self.animationCurveOptions = animationCurveOptions
        self.animationDuration = animationDuration
        self.originalEndFrame = originalEndFrame
        self.endFrame = endFrame
        self.intersectionRect = intersectionRect
        self.isUndocked = isUndocked
        self.isKeyboardVisible = isKeyboardVisible
        self.isLocalKeyboard = isLocalKeyboard
        self.isExternalKeyboardToolbar = isExternalKeyboardToolbar
        super.init()
    }
}

@objc
public final class KeyboardAppearanceObserver: NSObject {
    private static let thresholdForExternalKeyboardToolbar: CGFloat = 80

    @objc public weak var delegate: (any KeyboardAppearanceObserverDelegate)?

    @objc public weak var view: UIView?
    @objc public var isEnabled = false

    @objc public private(set) var lastInfo: KeyboardAppearanceObserverInfo?

    @objc
    public override init() {
        super.init()

        commonInit()
    }

    public init(lastInfo: KeyboardAppearanceObserverInfo? = nil) {
        self.lastInfo = lastInfo
        super.init()

        commonInit()
    }

    private func commonInit() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardFrameChangeNotification(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardFrameChangeNotification(_:)),
            name: UIResponder.keyboardDidChangeFrameNotification,
            object: nil
        )
    }
}

extension KeyboardAppearanceObserver {
    @objc private func handleKeyboardFrameChangeNotification(_ notification: Notification) {
        guard isEnabled else { return }

        let userInfo = notification.userInfo

        // frames in `userInfo` are in screen coordinates.
        guard let endFrameInScreen =
            (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }

        guard let targetCoordinateSpace = view?.coordinateSpace ?? window?.coordinateSpace else {
            return
        }

        let endFrame = screen.coordinateSpace.convert(endFrameInScreen, to: targetCoordinateSpace)
        let intersectionRect = targetCoordinateSpace.bounds.intersection(endFrame)

        // Workaround for iOS 16
        // In iOS 16, `endFrameInScreen` is incorrectly delivered in iPad Slide Over mode.
        // Compare `intersectionRect` and `targetCoordinateSpace.bounds`
        // instead of compare frames in screen coordinates.
        let isUndocked = UIDevice.current.userInterfaceIdiom == .pad
            ? round(intersectionRect.maxY) < round(targetCoordinateSpace.bounds.height)
            : false
        let isKeyboardVisible = round(intersectionRect.height) > 0

        let animationCurve = Self.animationCurve(from: userInfo)
        let animationDuration = Self.animationDuration(from: userInfo)
        let isLocalKeyboard = Self.isLocalKeyboard(from: userInfo)

        let isExternalKeyboardToolbar =
            endFrameInScreen.height < KeyboardAppearanceObserver.thresholdForExternalKeyboardToolbar

        let info = KeyboardAppearanceObserverInfo(
            animationCurve: animationCurve,
            animationCurveOptions: animationCurve.options(),
            animationDuration: animationDuration,
            originalEndFrame: endFrameInScreen,
            endFrame: endFrame,
            intersectionRect: intersectionRect,
            isUndocked: isUndocked,
            isKeyboardVisible: isKeyboardVisible,
            isLocalKeyboard: isLocalKeyboard,
            isExternalKeyboardToolbar: isExternalKeyboardToolbar
        )

        lastInfo = info

        if notification.name == UIResponder.keyboardWillChangeFrameNotification {
            delegate?.keyboardAppearanceObserverWillChange?(self, info: info)
        }
        else if notification.name == UIResponder.keyboardDidChangeFrameNotification {
            delegate?.keyboardAppearanceObserverDidChange?(self, info: info)
        }
    }

    private var screen: UIScreen {
        UIScreen.main
    }

    private var window: UIWindow? {
        if let window = view?.window {
            return window
        }
        else {
            return delegate?.keyboardAppearanceObserverWindow?(self)
        }
    }

    private static func animationCurve(from userInfo: [AnyHashable: Any]?) -> UIView.AnimationCurve {
        guard let number = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else {
            return .linear
        }
        guard let curve = UIView.AnimationCurve(rawValue: number.intValue) else {
            return .linear
        }
        return curve
    }

    private static func animationDuration(from userInfo: [AnyHashable: Any]?) -> TimeInterval {
        guard let number = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return 0
        }
        return number.doubleValue
    }

    private static func isLocalKeyboard(from userInfo: [AnyHashable: Any]?) -> Bool {
        guard let number = userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber else {
            return false
        }
        return number.boolValue
    }
}

extension KeyboardAppearanceObserver {
    public var iPadSlideOverBottomSpace: CGFloat {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return 0
        }
        guard let window else {
            return 0
        }
        let screen = screen
        let windowFrameInScreen = window.convert(window.bounds, to: screen.coordinateSpace)
        return screen.bounds.height - windowFrameInScreen.maxY
    }
}

@objc
public protocol KeyboardAppearanceObserverDelegate: AnyObject {
    @objc optional func keyboardAppearanceObserverWillChange(
        _ observer: KeyboardAppearanceObserver,
        info: KeyboardAppearanceObserverInfo
    )
    @objc optional func keyboardAppearanceObserverDidChange(
        _ observer: KeyboardAppearanceObserver,
        info: KeyboardAppearanceObserverInfo
    )
    @objc optional func keyboardAppearanceObserverWindow(_ observer: KeyboardAppearanceObserver) -> UIWindow?
}

extension UIView.AnimationCurve {
    public func options() -> UIView.AnimationOptions {
        // Resources:
        // https://stackoverflow.com/q/7327249
        assert(
            UIView.AnimationCurve.linear.rawValue << 16 == UIView.AnimationOptions.curveLinear.rawValue,
            "Unexpected implementation of UIViewAnimationCurve"
        )
        return UIView.AnimationOptions(rawValue: UInt(rawValue << 16))
    }
}
