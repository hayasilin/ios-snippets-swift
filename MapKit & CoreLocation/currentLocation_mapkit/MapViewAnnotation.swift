//
//  MapViewAnnotation.swift
//  currentLocation_mapkit
//
//  Created by Kuan-Wei Lin on 8/22/15.
//  Copyright (c) 2015 Kuan-Wei Lin. All rights reserved.
//

import MapKit
import UIKit

class MapViewAnnotation: NSObject {

    var latitude: CLLocationDegrees!
    var longtitude: CLLocationDegrees!
    var location: CLLocationCoordinate2D?
    var annotation: MKPointAnnotation?
    
    init(lat: CLLocationDegrees, long: CLLocationDegrees, titleAnn: String) {
        self.latitude = lat
        self.longtitude = long
    }
    
    func setLocation(){
        location = CLLocationCoordinate2DMake(self.latitude, self.longtitude)
    }
    
    func setAnnotations (titleAnn: String){
        annotation = MKPointAnnotation()
        annotation?.coordinate = location!
        annotation?.title = titleAnn
    }
    
    
}
