//
//  LocationService.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/24/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

public class LocationService: NSObject, CLLocationManagerDelegate{
    
    // 位置情報使用拒否Notification
    public let LSAuthDeniedNotification = "LSAuthDeniedNotification"
    // 位置情報使用制限Notification
    public let LSAuthRestrictedNotification = "LSAuthRestrictedNotification"
    // 位置情報使用可能Notification
    public let LSAuthorizedNotification = "LSAuthorizedNotification"
    // 位置情報取得完了Notification
    public let LSDidUpdateLocationNotification = "LSDidUpdateLocationNotification"
    // 位置情報取得失敗Notification
    public let LSDidFailLocationNotification = "LSDidFailLocationNotification"
    
    private let cllm = CLLocationManager()
    private let nsnc = NotificationCenter.default
    
    override init() {
        super.init()
        
        cllm.delegate = self
    }
    
    public func startUpdatingLocation(){
        cllm.startUpdatingLocation()
    }
    
    public var locationServiceDisabledAlert: UIAlertController {
        
        get{
            let alert = UIAlertController(title: "無法取得位置情報",
                                          message: "可以從設定>允許位置情報設定",
                                          preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            
            return alert
        }
    }
    
    public var locationServiceRestrictedAlert: UIAlertController {
        get {
            let alert = UIAlertController(title: "無法取得位置情報",
                                          message: "可以從設定>允許位置情報設定",
                                          preferredStyle: .alert)
            
            alert.addAction(
                UIAlertAction(title: "ok", style: .cancel, handler: nil)
            )
            
            return alert
        }
    }
    
    public var locationServiceDidFailAlert: UIAlertController {
        get {
            let alertView = UIAlertController(title: nil, message: "無法取得位置情報", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            return alertView
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            print("notDetermined")
            cllm.requestWhenInUseAuthorization()
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
        case .authorizedAlways:
            print("authorizedAlways")
        default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        cllm.stopUpdatingLocation()
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError = error \(error.localizedDescription)")
    }
    
}
