//
//  ShopPhotoEndViewController.swift
//  AllInOne
//
//  Created by KuanWei on 2018/1/12.
//  Copyright © 2018年 cracktheterm. All rights reserved.
//

import UIKit

class ShopPhotoEndViewController: UIViewController {

    var scrollView: UIScrollView!
    var imageView: UIImageView!

    var photo = UIImage()

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, _ photo: UIImage)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.photo = photo
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        navigationController?.navigationBar.isTranslucent = false
        tabBarController?.tabBar.isTranslucent = false

        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed(_:)))
        navigationItem.rightBarButtonItem = shareBarButtonItem

        imageView = UIImageView(image: photo)

        scrollView = UIScrollView(frame: view.bounds)
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.black
        scrollView.contentSize = imageView.bounds.size
        scrollView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))

        scrollView.addSubview(imageView)
        view.addSubview(scrollView)

        setZoomScale()
        setupDoubleTapGestureRecognizer()
    }

    @objc func shareButtonPressed(_ sender: UIBarButtonItem)
    {
        let shareScreen = UIActivityViewController(activityItems: [photo], applicationActivities: nil)
        self.present(shareScreen, animated: true, completion: nil)
    }

    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()

        setZoomScale()
    }

    func setZoomScale()
    {
        let widthScale = scrollView.bounds.size.width / imageView.bounds.width
        let heightScale = scrollView.bounds.size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)

        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }

    func setupDoubleTapGestureRecognizer()
    {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }

    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer)
    {
        if scrollView.zoomScale > scrollView.minimumZoomScale
        {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
        else
        {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
}

extension ShopPhotoEndViewController: UIScrollViewDelegate
{
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView)
    {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size

        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0

        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }



}






