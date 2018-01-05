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

    //UI
    @IBOutlet weak var mapView: MKMapView!
    var myLocationButton: UIButton!
    var filterButton: UIButton!
    
    var rollOutView: UIView!
    var rollOutViewHeight: CGFloat = 300
    var rollOutViewMargin: CGFloat = 100
    
    var shopListVC = ShopListViewController()

    var selectedPin: MKPointAnnotation!

    var tabBarHeight: CGFloat!

    //Controller
    var isFirstEntry = true

    //LocationService
    let locationService = LocationService()
    
    //Data
    let apiService: APIServiceProtocol = APIService()
    var allShops = [Shop]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isTranslucent = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarHeight = (tabBarController?.tabBar.frame.size.height)!

        checkShareConfiguration()

        createUI()
        createShopListUI()

        //Init location Service delegate
        createLocationService()
    }

    func checkShareConfiguration()
    {
        if UIApplication.shared.canOpenURL(URL(string: "line://")!)
        {
            print("User has LINE App")
        }
        else
        {
            print("User doesn't have LINE App")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if filterButton.isHidden
        {
            toggleViewDown()
            filterButton.isHidden = false
        }
    }
    
    func createUI()
    {
        rollOutView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: self.rollOutViewHeight))
        rollOutView.backgroundColor = UIColor.blue
        view.addSubview(rollOutView)
        
        let swipeDownGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(toggleViewDown))
        swipeDownGesture.direction = UISwipeGestureRecognizerDirection.down
        rollOutView.addGestureRecognizer(swipeDownGesture)
        
        myLocationButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.maxX - 68, y: UIScreen.main.bounds.size.height - 120, width: 52, height: 52))
        let locationImage = UIImage(named: "user_location_button")
        myLocationButton.setImage(locationImage, for: .normal)
        myLocationButton.addTarget(self, action: #selector(showUserLoaction), for: .touchUpInside)
        view.addSubview(myLocationButton)
        
        filterButton = UIButton(frame: CGRect(x: 16, y: UIScreen.main.bounds.size.height - self.rollOutViewHeight - 80, width: 52, height: 52))
        let filterImage = UIImage(named: "filter_button")
        filterButton.setImage(filterImage, for: .normal)
        filterButton.addTarget(self, action: #selector(doFilterAction), for: .touchUpInside)
        view.addSubview(filterButton)
        filterButton.isHidden = true
    }

    func createShopListUI()
    {
        shopListVC.delegate = self
        shopListVC.view.frame = rollOutView.bounds
        rollOutView.addSubview(shopListVC.view)
    }
    
    @objc func doFilterAction()
    {
        toggleViewUp()
    }
    
    @objc func toggleViewUp()
    {
        var frame = rollOutView.frame
        var myLocationButtonFrame = myLocationButton.frame
        var filterButtonFrame = filterButton.frame
        
        if rollOutView.frame.origin.y == UIScreen.main.bounds.size.height
        {
            frame.origin.y = UIScreen.main.bounds.size.height - rollOutViewHeight - tabBarHeight
            myLocationButtonFrame.origin.y = UIScreen.main.bounds.size.height - rollOutViewHeight - tabBarHeight - 80
            filterButtonFrame.origin.y = UIScreen.main.bounds.size.height - rollOutViewHeight - tabBarHeight - 80
            
            filterButton.isHidden = true
            
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
            self.myLocationButton.frame = myLocationButtonFrame
            self.filterButton.frame = filterButtonFrame
        }) { (finished) in
            self.shopListVC.view.removeFromSuperview()
            self.rollOutView.addSubview(self.shopListVC.view)
        }
    }
    
    @objc func toggleViewDown()
    {
        var frame = rollOutView.frame
        var myLocationButtonFrame = myLocationButton.frame
        var filterButtonFrame = filterButton.frame
        
        if rollOutView.frame.origin.y == UIScreen.main.bounds.size.height - rollOutViewMargin
        {
            //Do nothing
        }
        else
        {
            frame.origin.y = UIScreen.main.bounds.size.height
            myLocationButtonFrame.origin.y = UIScreen.main.bounds.size.height - 120
            filterButtonFrame.origin.y = UIScreen.main.bounds.size.height - 120
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.rollOutView.frame = frame
            self.myLocationButton.frame = myLocationButtonFrame
            self.filterButton.frame = filterButtonFrame
        }) { (finished) in
            self.shopListVC.view.removeFromSuperview()
            self.rollOutView.addSubview(self.shopListVC.view)
        }
    }
    
    func createLocationService()
    {
        mapView.showsUserLocation = true
        mapView.showsBuildings = true
        mapView.showsPointsOfInterest = true

        locationService.delegate = self
        locationService.startUpdatingLocation()
    }
    
    func moveMapViewUp()
    {
        var center = mapView.userLocation.coordinate
        center.latitude -= mapView.region.span.latitudeDelta * 0.10
        mapView.setCenter(center, animated: true)
    }
    
    @objc func showUserLoaction()
    {
        let userLocation: MKUserLocation = mapView.userLocation
        var region = MKCoordinateRegion()
        region.center = userLocation.coordinate
        region = MKCoordinateRegionMakeWithDistance(region.center, 1000, 1000)

        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
//        print("regionWillChangeAnimated")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        print("regionDidChangeAnimated")
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
//        print("mapViewWillStartLoadingMap")
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
//        print("mapViewDidFinishLoadingMap")
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("mapViewDidFailLoadingMap")
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
//        print("mapViewWillStartRenderingMap")
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        print("mapViewDidFinishfullyRenderedMap")
        if isFirstEntry {
            isFirstEntry = false
            showUserLoaction()
        }
    }
    
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
//        print("mapViewWillStartLocatingUser")
    }
    
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
//        print("mapViewDidStopLocatingUser")
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        print("didUpdate")
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
//        print("didChange")
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is MKUserLocation
        {
            return nil
        }

        let reusedID = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusedID) as? MKPinAnnotationView

        if pinView == nil
        {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusedID)
            pinView?.canShowCallout = true
//            pinView?.animatesDrop = true
        }
        else
        {
            pinView?.annotation = annotation
        }


        return pinView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        let shopName = view.annotation?.title
        toggleViewUp()

        shopListVC.selectShopFromListByName(shopName!!)


    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped")
    }
}

extension MapViewController: LocationServiceProtocol {
    
    func lsDidUpdateLocation(_ location: CLLocation)
    {
        apiService.fetchShopData(location.coordinate.latitude, location.coordinate.longitude) { (success, shops, error) in

            self.allShops = shops

            for shop in shops {
                let ann = MKPointAnnotation()
                ann.coordinate = CLLocationCoordinate2DMake(shop.lat!, shop.lon!)
                ann.title = shop.name
                ann.subtitle = shop.address
                self.mapView.addAnnotation(ann)
            }

            self.shopListVC.getShopData(shops, completion: {
                self.toggleViewUp()
            })
        }
    }
}

extension MapViewController: ShopListViewControllerProtocol {

    func didSelectShopAtIndexPath(_ indexPath: IndexPath) {
        print("\(indexPath.row)")
        let shop = self.allShops[indexPath.row]

        //地圖範圍
        var coordinate = CLLocationCoordinate2DMake(shop.lat!, shop.lon!)
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500)
        mapView.setRegion(region, animated: true)

        //加pin
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = shop.name
        pin.subtitle = shop.address
        mapView.addAnnotation(pin)

        self.mapView.selectAnnotation(pin, animated: true)

        //將MapView往上移動一點
        coordinate.latitude -= mapView.region.span.latitudeDelta * 0.10
        mapView.setCenter(coordinate, animated: true)
    }
}
