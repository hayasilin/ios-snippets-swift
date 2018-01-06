//
//  ShopDetailViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 1/6/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import UIKit
import SDWebImage
import MapKit
import Social

class ShopDetailViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var lineButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    
    
    var shop = Shop()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, _ shop: Shop) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.shop = shop
        
        print("self.shop = \(self.shop)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isTranslucent = false
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        createUI()
        checkShareConfiguration()
    }
    
    func createUI()
    {
        let url = URL(string: shop.photoUrl!)
        imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "no_image"), options: SDWebImageOptions(rawValue: 0), completed: nil)
        
        shopNameLabel.text = shop.name
        phoneButton.setTitle(shop.tel, for: .normal)
        addressButton.setTitle(shop.address, for: .normal)
        
        let cllc = CLLocationCoordinate2D(latitude: shop.lat!, longitude: shop.lon!)
        let mkcr = MKCoordinateRegionMakeWithDistance(cllc, 200, 200)
        mapView.setRegion(mkcr, animated: false)

        let pin = MKPointAnnotation()
        pin.coordinate = cllc
        pin.title = shop.name
        pin.subtitle = shop.address
        mapView.addAnnotation(pin)
    }
    
    func checkShareConfiguration()
    {
        if UIApplication.shared.canOpenURL(URL(string: "line://")!)
        {
            lineButton.isEnabled = true
        }
    }
    
    func share(_ type: String)
    {
        let vc = SLComposeViewController(forServiceType: type)
        if let name = shop.name
        {
            vc?.setInitialText(name + "\n")
        }
//        if let gid = shop.gid
//        {
//
//        }
        if let urlString = shop.url
        {
            vc?.add(URL(string: urlString))
        }
        
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func phoneButtonPressed(_ sender: UIButton)
    {
        if let tel = shop.tel
        {
            let telUrl = URL(string: "tel:\(tel)")
            
            if !UIApplication.shared.canOpenURL(telUrl!)
            {
                let alert = UIAlertController(title: "無法打電話", message: "這台裝置並沒有電話功能", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            }
            else
            {
                if let name = shop.name {
                    let alert = UIAlertController(title: name, message: "打電話給 \(name) 嗎？", preferredStyle: .alert)
                    alert.addAction(
                        UIAlertAction(title: "打電話", style: .destructive, handler: { (action) in
                            UIApplication.shared.open(telUrl!, options: [:], completionHandler: nil)
                            return
                        })
                    )
                    alert.addAction(
                        UIAlertAction(title: "取消", style: .cancel, handler: nil)
                    )
                    present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func addressButtonPressed(_ sender: UIButton)
    {
        
    }
    
    @IBAction func shareLineButtonPressed(_ sender: UIButton)
    {
        var message = ""
        if let name = shop.name {
            message += name + "\n"
        }
        if let url = shop.url {
            message += url + "\n"
        }
        if let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        {
            if let url = URL(string: "line://msg/text/" + encoded)
            {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func shareFacebookButtonPressed(_ sender: UIButton)
    {
        share(SLServiceTypeFacebook)
    }
    
    @IBAction func shareTwitterButtonPressed(_ sender: UIButton)
    {
        share(SLServiceTypeTwitter)
    }
    
}

extension ShopDetailViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let scrollOffset = scrollView.contentOffset.y + scrollView.contentInset.top + (navigationController?.navigationBar.frame.height)!
        if scrollOffset <= 0
        {
            imageView.frame.origin.y = scrollOffset
            imageView.frame.size.height = 200 - scrollOffset
        }
        
    }
}








