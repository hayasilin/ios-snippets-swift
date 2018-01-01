//
//  MapViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit
import MapKit

let apiRequestUrl = "https://map.yahooapis.jp/search/local/V1/localSearch?appid=dj0zaiZpPUhhdVJPbm9hMnVUMSZzPWNvbnN1bWVyc2VjcmV0Jng9ZmE-&device=mobile&group=gid&sort=score&output=json&gc=01&query=%E3%83%8F%E3%83%B3%E3%83%90%E3%83%BC%E3%82%AC%E3%83%BC&lat=35.7020691&lon=139.7753269&dist=3"

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationService = LocationService()
    var isFirstEntry = true
    
    let requestManager: RestfulRequestManager = RestfulRequestManager.sharedInstance
    var shops = [Shop]()
    
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
        
        createLocationService()
        
        showUserLoaction()
        
        requestDataFromAPI()
    }
    
    func requestDataFromAPI()
    {
        let url = URL(string: apiRequestUrl)
        
        try? requestManager.get(url: url!, completionHandler: { (data, urlResponse, error) in
            
            let responseObj = try? JSONSerialization.jsonObject(with: data!) as! [String : AnyObject]
            print("responseObj = \(String(describing: responseObj))")
            
            if let arrJSON = responseObj {
                
                if let value = arrJSON["ResultInfo"]
                {
                    let totalCount = value["Total"] as? String
                    print("total = \(String(describing: totalCount))")
                    
                    if value["Status"] as! Int == 200
                    {
                        for item in arrJSON["Feature"] as! [AnyObject]
                        {
                            print("start parsing")
                            var shop = Shop()
                            shop.gid = item["Gid"] as? String
                            shop.name = item["Name"] as? String
                            
                            let geometry = item["Geometry"] as! [String: String]
                            let coordinates = geometry["Coordinates"]
                            let components = coordinates?.components(separatedBy: ",")
                            shop.lat = Double(components![1])
                            shop.lon = Double(components![0])
                            
                            let property = item["Property"] as! [String: AnyObject]
                            shop.yomi = property["Yomi"] as? String
                            shop.tel = property["Tel1"] as? String
                            shop.address = property["Address"] as? String
                            shop.catchCopy = property["CatchCopy"] as? String
                            shop.photoUrl = property["LeadImage"] as? String
                            
                            if let stations = property["Station"] as? [[String: String]] {
                                var line = ""
                                let lineString = stations[0]
                                let lineName = lineString["Railway"]
                                let lines = lineName?.components(separatedBy: "/")
                                line = lines![0]
                                
                                let stationDict = stations[0]
                                if let stationName = stationDict["Name"] {
                                    shop.station = "\(line) \(stationName)"
                                }
                                else
                                {
                                    shop.station = "\(line)"
                                }
                            }
 
                            self.shops.append(shop)
                        }
                        
                    }
                }
                else
                {
                    let alert = UIAlertController(title: "喔喔！", message: "資料取得失敗，請往下滑再試一次", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
        
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
