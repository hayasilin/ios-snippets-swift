//
//  ViewController.swift
//  Demo
//
//  Created by user on 2022/11/29.
//

import UIKit
import SafariServices

/// https://medium.com/@pallavidipke07/method-swizzling-in-swift-5c9d9ab008e4
/// swizzling viewWillAppear example

/// https://www.guardsquare.com/blog/swift-native-method-swizzling
/// More complex swizzling scenario explanation
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pushNextPage))
        navigationItem.rightBarButtonItem = navigationBarButtonItem

        Swizzler.swizzleSelector(
            #selector(Foo.originalMethod),
            of: Foo.self,
            with: #selector(Foo.firstSwizzledMethod)
        )
        
        let foo = Foo()
        foo.originalMethod()
//        let bar = Bar()
//        bar.originalMethod()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
    }

    @objc
    func pushNextPage() {
        let detailVC = DetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension UIViewController {
    class func swizzleMethod() {
        let originalSelector = #selector(UIViewController.viewWillAppear)
        let swizzleSelector = #selector(UIViewController.swizzleViewWillAppear(_:))

        guard
            let originMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
            let swizzleMethod = class_getInstanceMethod(UIViewController.self, swizzleSelector)
        else {
            return
        }

        method_exchangeImplementations(originMethod, swizzleMethod)
    }

    @objc func swizzleViewWillAppear(_ animated: Bool) {
        print(#function) // call first before viewWillAppear
        // https://stackoverflow.com/questions/30695895/difference-between-method-swizzling-and-category-in-objective-c
        /*
         The line makes a call to `swizzleViewWillAppear(_:) method, which looks like an call to itself that should cause infinite recursion.
         However, this is not what happens. After swizzling, this call gets transformed into a call to the original `viewWillAppear(_:)`
         because of the way method swizzling works.
         */
        swizzleViewWillAppear(animated)
    }
}

class Foo: NSObject {
    // https://stackoverflow.com/questions/60360881/how-to-swizzle-method-of-class-with-some-customized-method-through-extension
    // Custom function need to add dynamic to make swizzling work
    @objc dynamic func originalMethod() {
        print(#function)
    }
}

extension Foo {
    @objc dynamic func firstSwizzledMethod() {
        print(#function)
        firstSwizzledMethod() // Executes original implementation
    }
}
extension Foo {
    @objc dynamic func secondSwizzledMethod() {
        print(#function)
        secondSwizzledMethod()
    }
}

class Bar: Foo {
    override func originalMethod() {
        print(#function)
    }

    override func firstSwizzledMethod() {
        print(#function)
        firstSwizzledMethod()
    }
}

@objc public class Swizzler: NSObject {
    @objc(swizzleSelector:ofClass:withSelector:)
    public static func swizzleSelector(_ original: Selector, of cls: AnyClass, with new: Selector) {
        guard let originalMethod = class_getInstanceMethod(cls, original),
              let newMethod = class_getInstanceMethod(cls, new)
        else {
            return
        }

        if class_addMethod(cls, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)) {
            let implementation = method_getImplementation(originalMethod)
            let types = method_getTypeEncoding(originalMethod)
            class_replaceMethod(cls, new, implementation, types)
        }
        else {
            method_exchangeImplementations(originalMethod, newMethod)
        }
    }

    @objc(swizzleClassSelector:ofClass:withSelector:)
    public static func swizzleClassSelector(_ original: Selector, of cls: AnyClass, with new: Selector) {
        guard let metaClass = object_getClass(cls) else { return }
        swizzleSelector(original, of: metaClass, with: new)
    }

    @objc(swizzleSelectorFromString:ofClass:withSelectorFromString:)
    public static func swizzleSelector(from originalStr: String, of cls: AnyClass, withSelectorFrom newStr: String) {
        let original = NSSelectorFromString(originalStr)
        let new = NSSelectorFromString(newStr)
        swizzleSelector(original, of: cls, with: new)
    }
}
