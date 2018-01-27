//
//  VIewController1.swift
//  currentLocation_mapkit
//
//  Created by Kuan-Wei Lin on 8/22/15.
//  Copyright (c) 2015 Kuan-Wei Lin. All rights reserved.
//

import UIKit
import CoreLocation

class VIewController1: UIViewController, CLLocationManagerDelegate {
    var clm: CLLocationManager!
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var horizontalLabel: UILabel!
    @IBOutlet weak var verticalLabel: UILabel!
    
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.clm = CLLocationManager()
        clm.requestWhenInUseAuthorization()
        clm.requestAlwaysAuthorization()
        clm.startUpdatingHeading()
        print(clm)
        
        if CLLocationManager.locationServicesEnabled(){
            clm.delegate = self
            //發生事件的最小距離
            clm.distanceFilter = kCLDistanceFilterNone
            //精度
            clm.desiredAccuracy = kCLLocationAccuracyBest
            clm.requestWhenInUseAuthorization()
            clm.requestAlwaysAuthorization()
            //開始定位
            clm.startUpdatingHeading()
            //動方向
            clm.startUpdatingHeading()
            print("啟動定位")
            print(clm)
        }else{
            print("沒有啟動定位")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location : NSArray = locations as NSArray!
        let newLocation: CLLocation = location.objectAtIndex(0) as! CLLocation
        let timestamp : NSDate = newLocation.timestamp
        timestampLabel.text = "\(timestamp)"
        
        
        //緯度，精度
        let coordinate: CLLocationCoordinate2D = newLocation.coordinate
        let latitude: CLLocationDegrees = coordinate.latitude
        let longitude: CLLocationDegrees = coordinate.longitude
        latitudeLabel.text = "\(latitude)"
        longitudeLabel.text = "\(longitude)"
        
        //撰寫半徑精度，高度精度
        let horizontal: CLLocationAccuracy = newLocation.horizontalAccuracy
        let vertical: CLLocationAccuracy = newLocation.verticalAccuracy
        horizontalLabel.text = "\(horizontal)"
        verticalLabel.text = "\(vertical)"
        
        let altitude: CLLocationDistance = newLocation.altitude
        let course: CLLocationDirection = newLocation.course
        altitudeLabel.text = "\(altitude)"
        courseLabel.text = "\(course)"
        
        let speed: CLLocationSpeed = newLocation.speed
        speedLabel.text = "\(speed)"
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
