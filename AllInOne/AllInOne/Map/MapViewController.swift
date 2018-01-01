//
//  MapViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController{

    @IBOutlet weak var mapView: MKMapView!
    let locationService = LocationService()
    var isFirstEntry = true
    
    let apiService: APIServiceProtocol = APIService()
    var allShops = [Shop]()
    
    var rollOutView: UIView!
    var rollOutViewHeight = CGFloat()
    var rollOutViewMargin = CGFloat()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isTranslucent = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        navigationItem.title = "Map";
        
        if UIApplication.shared.canOpenURL(URL(string: "line://")!) {
            print("User has LINE App")
        }
        else
        {
            print("User doesn't have LINE App")
        }
        
        locationService.delegate = self
        
        createLocationService()
        
        showUserLoaction()
        
        apiService.fetchShopData { [weak self] (success, shops, error) in
            self?.allShops = shops
            print("allShops = \(String(describing: self?.allShops))")
        }
        
        rollOutViewHeight = 300;
        rollOutViewMargin = 100;
        
        createUI()
    }
    
    func createUI()
    {
        rollOutView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: self.rollOutViewHeight))
        rollOutView.backgroundColor = UIColor.blue
        view.addSubview(rollOutView)
        
        let swipeDownGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(toggleViewDown))
        swipeDownGesture.direction = UISwipeGestureRecognizerDirection.down
        rollOutView.addGestureRecognizer(swipeDownGesture)
    }
    
    @objc func toggleViewUp()
    {
        var frame = rollOutView.frame
        
        if rollOutView.frame.origin.y == UIScreen.main.bounds.size.height
        {
            frame.origin.y = UIScreen.main.bounds.size.height - self.rollOutViewHeight
            
            //讓mapView往上移一點
            var center: CLLocationCoordinate2D = mapView.centerCoordinate
            center.latitude -= mapView.region.span.latitudeDelta * 0.10
            mapView.setCenter(center, animated: true)
        }
        else
        {
            //Do nothing
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.rollOutView.frame = frame
        }) { (finished) in
            
        }
    }
    
    @objc func toggleViewDown()
    {
        var frame = rollOutView.frame
        
        if rollOutView.frame.origin.y == UIScreen.main.bounds.size.height - rollOutViewMargin
        {
            //Do nothing
        }
        else
        {
            frame.origin.y = UIScreen.main.bounds.size.height
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.rollOutView.frame = frame
        }) { (finished) in
            
        }
    }
    
    func createLocationService()
    {
        locationService.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapView.showsBuildings = true
        mapView.showsPointsOfInterest = true
    }
    
    func showUserLoaction()
    {
        let userLocation: MKUserLocation = mapView.userLocation
        
        print("user lat = \(userLocation.coordinate.latitude)")
        print("user lon = \(userLocation.coordinate.longitude)")
        
        var region = MKCoordinateRegion()
        region.center = userLocation.coordinate
        region = MKCoordinateRegionMakeWithDistance(region.center, 1000, 1000)
        
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func showUserLocationAction(_ sender: UIButton)
    {
        showUserLoaction()
    }
    
}

extension MapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("regionWillChangeAnimated")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated")
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        print("mapViewWillStartLoadingMap")
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("mapViewDidFinishLoadingMap")
        if isFirstEntry
        {
            isFirstEntry = false
            showUserLoaction()
            
        }
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("mapViewDidFailLoadingMap")
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        print("mapViewWillStartRenderingMap")
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        print("mapViewDidFinishRenderingMap")
    }
    
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        print("mapViewWillStartLocatingUser")
    }
    
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        print("mapViewDidStopLocatingUser")
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("didUpdate")
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        print("didChange")
    }
}

extension MapViewController: LocationServiceProtocol {
    
    func lsDidUpdateLocation(_ location: CLLocation)
    {
        perform(#selector(toggleViewUp), with: nil, afterDelay: 1)
    }
}
