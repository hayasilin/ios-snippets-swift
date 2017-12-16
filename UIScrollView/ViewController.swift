//
//  ViewController.swift
//  SwiftDemo
//
//  Created by Kuan-Wei Lin on 12/16/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var imageViews = [UIImageView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.frame = UIScreen.main.bounds
        scrollView.isPagingEnabled = true
        view.addSubview(scrollView)
        
        imageViews.append(UIImageView(image: UIImage(named: "a")))
        imageViews.append(UIImageView(image: UIImage(named: "b")))
        imageViews.append(UIImageView(image: UIImage(named: "c")))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let rect = scrollView.bounds
        var size = CGSize()
        var left: UIImageView? = nil
        
        for imageView in imageViews{
            imageView.contentMode = .scaleAspectFit
            
            if left == nil{
                imageView.frame = rect
            }
            else
            {
                imageView.frame = left!.frame.offsetBy(dx: left!.frame.size.width, dy: 0)
            }
            
            left = imageView
            
            size = CGSize(width: size.width + imageView.frame.size.width, height: rect.size.height)
            
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = size
    }
    
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

