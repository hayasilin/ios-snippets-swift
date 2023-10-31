//
//  DetailViewController.swift
//  Demo
//
//  Created by user on 2023/04/13.
//

import UIKit
import Foundation

class DetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray

        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 12)
    }
}

extension UILabel {
    static func swizzleMethods() {
        Swizzler.swizzleSelector(from: "setFont:", of: UILabel.self, withSelectorFrom: "swizzle_setFont:")
    }

    @objc(swizzle_setFont:)
    func swizzle_setFont(_ font: UIFont?) {
        print(#function)
        swizzle_setFont(font)
    }
}
